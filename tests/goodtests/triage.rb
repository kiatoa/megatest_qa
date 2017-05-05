#!/usr/bin/env ruby
#!/usr/intel/pkgs/ruby/1.8.7-p72/bin/ruby
#!/usr/intel/pkgs/ruby/2.3.0/bin/ruby

#dir = "."
#if ARGV.length == 1
#  dir = ARGV[0]
#end
#puts dir
#exit 1

argv=ARGV
allfiles = []

argv.each{|dir|
  server_logs = `find -L #{dir}/. logs/ -type f -name 'server*.log' 2>/dev/null`.split /\n/
  nbfiles = `find -L #{dir}/. -type f -name '##*' 2>/dev/null`.split /\n/
  fakefiles = `find -L #{dir}/. -type f -name 'NBFAKE-*' 2>/dev/null`.split /\n/
  allfiles = allfiles + nbfiles + fakefiles + server_logs
}

if argv.length == 0
  argv = ['ALLTESTS']
end

if argv.member?("ALLTESTS")
  `sqlite3 megatest.db "select rundir from tests where rundir<>'/tmp/badname'"`.split.each{|dir|
    #puts dir
    nbfiles = `find #{dir}/. -type f -name '##*' 2>/dev/null`.split /\n/
    fakefiles = `find #{dir}/. -type f -name 'NBFAKE-*' 2>/dev/null`.split /\n/
    #puts nbfiles
    allfiles = allfiles + nbfiles + fakefiles
  }
end

buckets = Hash.new{|h,k| h[k]=[]}
#;buckets['OK'] = []
#;buckets['stackdump'] = []


sig_patterns = [
                'cannot create directory - File exists',
                'in thread: \(finalize!\) bad argument type - not a database or statement: #<unspecified>',
                'cannot delete file - No such file or directory: .*\/.runconfig.',
                'Error: \(hash-table-ref/default\) bad argument type - not a structure of the required type',
                '\(#<thread: Watchdog thread>\): in thread: \(open-output-file\) cannot open file - File exists:',
                'http-transport.scm:442: posix-extras#change-file-times',
                'thread: \(file-exists\?\) system error while trying to access file:',
                'error: database is locked',
                'Finalizing failed, unable to close due to unfinalized statements or unfinished backups',
                'rmt.scm:276: current-milliseconds',
                'http-transport.scm:366: exit',
                'should never happen',
                'FATAL: \*configdat\* was inaccessible! This should never happen.',
                'This should never happen',
                'Brute force',
                '!!ISOENV PRESENT!!',
                'cannot create socket - Connection refused'
               ]

if allfiles.length == 0
  puts "Cannot find any files to scan."
  exit 0
end

allfiles.each{|logfile|
  bucket = 'OK'
  if (File.exists? logfile)
    open(logfile){|fh|
      fh.each{|line|
        #bucket='??'
        if line.match(/Call history/)
          if bucket == 'OK'
            bucket='??'
          end
        end
        sig_patterns.each_with_index{|pat,bucket_name|
          #bucket_name,pat = i
          if line.match(/#{pat}/)
            bucket=bucket_name
          end
        }
        
      }
    }
    buckets[bucket] << logfile
  end
}

$exitcode = 0
#puts "count\tsignature\texample file"
buckets.keys.each{|bucket|
  if bucket != 'OK'
    $exitcode = 1
  end
  count = buckets[bucket].length

  example = buckets[bucket][0]
  if example
    fullpath = `readlink -f #{example}`
    #puts "BB> #{bucket}"
    pat = ""
    if bucket == 'OK'
      pat = ""
    elsif bucket == '??'
      pat = "Call history (scheme stack dump)"
    else 
      pat = "/#{sig_patterns[bucket]}/"
    end
        
    puts "#{count}\tsignature-#{bucket}\t#{pat}"
    if bucket.to_s.match(/^([0-9]+|\?\?)$/)
      puts "                   +-- <a href=\"file://#{fullpath}\">unix link</a>  <a href=\"\\\\samba.pdx.intel.com#{ fullpath.gsub(/\//,"\\") }\">samba link</a>"
      puts "                   `-- path = #{fullpath}"
    end
  else
    puts "#{count}\tsignature-#{bucket}"
  end
}

exit $exitcode
#if puts buckets['??'].length > 0
#  puts "unknown signatures"
#  puts buckets['??'][0]
#end
