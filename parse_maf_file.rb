#!/usr/bin/env ruby

require 'optparse'
require '/home/sra/programming/ruby/maf_parser/parse_maf.rb'

class ParseMaf
	def self.parse(args)
		puts "parse"

		options = {:name => nil, :report => nil}
        parser = OptionParser.new do|opts|



            opts.banner = "Usage: maf_parser.rb [options]"
            opts.on('-m', '--maf name', 'MAF file') do |name|
                options[:name] = name;
            end

            opts.on('-r', '--report ', 'Report file') do |report|
                options[:report] = report;
            end

						opts.on("-c", "--cutoff ", "cutoff for insertion") do |cut_off|
								options[:cut_off] = cut_off.to_i;
						end


            opts.on('-h', '--help', 'Display Help') do
                puts opts
                exit
            end
        end

        parser.parse!

		options
		
	end


end

options = ParseMaf.parse(ARGV)
m = MafParser.new(options)
m.run()
