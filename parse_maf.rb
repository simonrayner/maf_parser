#!/usr/bin/env ruby 



class MafParser


	def initialize(options)
		puts options
		@maf_file 		= options[:name]
		@report_file 	= options[:report]
		@cut_off			= options[:cut_off]

		raise "no cut off defined" if @cut_off.nil?
		@fragments = []

		
	end

	def run
		puts "MAF: #{@maf_file}"
		puts "REP:#{@report_file}"

		seq_count = 0
		seq_pair = []
		fh_report = File.open(@report_file, "w")
		File.open(@maf_file, 'r').each do |line|  
			# skip header line
			next if line[0] == '#'
			if line[0] == 'a'
				if seq_count == 2
					if @mult == 2
puts seq_pair[0]["src"]
					  hits = analyze_fragment(seq_pair)
						write_fragment_data(hits, fh_report)
					end
					@score = 0
					@label = ""
					@mult = 0
					seq_pair.clear
					seq_count = 0
				end
				@score = line.split(" ")[1].split("=")[1]
				@label = line.split(" ")[2].split("=")[1]
				@mult  = line.split(" ")[3].split("=")[1].to_i
		
			end

			if line[0] == 's'
				puts line[0..60]
				src 				= line.split(" ")[1]
				start 			= line.split(" ")[2].to_i
				size				= line.split(" ")[3].to_i
				strand			= line.split(" ")[4]
				feat_len		= line.split(" ")[5].to_i
				seq					= line.split(" ")[6]
				# puts "#{src}, #{start}, #{size}, #{strand}"
				seq_pair << {"src" => src, "start" => start, "size" => size, "strand" => strand, "feat_len" => feat_len, "seq" => seq, "label" => @label}
				seq_count += 1
			end


		end  
		fh_report.close
	end


	# here we identify insertions and deletions in the pairwise alignment that are longer than a 
	# user defined threshold.
	def analyze_fragment(data)
		
		frags = []		

		puts "analyze fragment"
		# there should only be two entries in the hash, we want data[0][seq:] & data[1][seq:]
		puts "--AF:#{data[0]["src"]}"
		puts "--AF:#{data[0]["src"]}|#{data[0]["start"]}|#{data[0]["strand"]}"
		offset = 0
	 	while data[0]["seq"].index('-'*@cut_off, offset) != nil
			start = data[0]["seq"].index('-'*@cut_off, offset)
			# this is the start in the string, not the true location of the insert in the sequence
			# to calculate this, need to count how many inserts (i.e. '-' are in the preceding string)
			# puts "preceding string length#{data[0]["seq"][0..start-1].length}:start shifts from #{start}-->#{start - data[0]["seq"][0..start-1].count("-")}: del #{data[0]["seq"][0..start-1].count("-")}"

			true_start = start - data[0]["seq"][0..start-1].count("-")
 			# puts "--HIT:#{data[0]["seq"].index('-'*@cut_off, offset)}|#{offset}|#{data[0]["seq"][offset]}"
			# get length of insert
			offset = start + @cut_off + 1
			while data[0]["seq"][offset] == '-' 
				offset+=1
			end
			puts "---- #{ data[0]["src"]} insert runs from #{data[0]["start"]+start+1}(#{start+1}) to #{data[0]["start"]+offset }(#{offset})-->#{ data[0]["label"]}"
			frags << {"src" =>  data[0]["src"], "true_start" => data[1]["start"]+true_start+1, "start" => data[0]["start"]+start+1, "stop" => data[0]["start"]+offset, "strand" => data[0]["strand"], "label" => data[0]["label"]}
		end


    puts "--AF:#{data[1]["src"]}|#{data[1]["start"]}|#{data[0]["strand"]}"
    offset = 0
    while data[1]["seq"].index('-'*@cut_off, offset) != nil
      start = data[1]["seq"].index('-'*@cut_off, offset)
			true_start = start - data[1]["seq"][0..start-1].count("-")
      # puts "--HIT:#{data[0]["seq"].index('-'*@cut_off, offset)}|#{offset}|#{data[0]["seq"][offset]}"
      # get length of insert
      offset = start + @cut_off + 1
      while data[1]["seq"][offset] == '-'
        offset+=1
      end
      puts "---- #{ data[1]["src"]} insert runs from #{data[1]["start"]+start+1}(#{start+1}) to #{data[1]["start"]+offset }(#{offset})"
			frags << {"src" =>  data[1]["src"], "true_start" => data[1]["start"]+true_start+1, "start" => data[1]["start"]+start+1, "stop" => data[1]["start"]+offset, "strand" => data[1]["strand"], "label" => data[1]["label"]}
		end

		frags

	end


	def write_fragment_data(frags, fh)
		frags.each do |frag|

			fh.puts("#{frag["src"]}\t#{frag["true_start"]}\t#{frag["start"]}\t#{frag["stop"]}\t#{frag["strand"]}\t#{frag["label"]}\t#{frag["stop"]-frag["start"]+1}")

		end

	end

end
