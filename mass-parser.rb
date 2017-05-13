#!/usr/bin/env ruby2.1
# Copyright (C) 2016 Sebastian Ehlert
#
# This program is free software: you can redistribute it and/or 
# modify it under the terms of the GNU General Public License as 
# published by the Free Software Foundation, either version 3 of 
# the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  
# If not, see <http://www.gnu.org/licenses/>.

require 'optparse'
require_relative 'yamsp'

usage = "Benutzung: ruby mass-parser [Optionen] Summenformeln"
options = {}
OptionParser.new do |opts|
    opts.banner = usage +
    "\nDiese Version unterstützt die ersten drei Perioden.\n\n"
    opts.on "-m","--ionisation-method METHOD",
        "Auswahl einer Ionisierungsmethode" do |method| 
            options[:method] = method
    end
    opts.on "-n","--neutral",
        "Berechnet exakte Masse für neutrales Teilchen" do |neutral|
        options[:neutral] = neutral
    end
    opts.on "-v","--verbose",
        "Auskunft über die einzelnen Arbeitsschritte" do |verbose|
        options[:verbose] = verbose
    end
    opts.on_tail "-h","--help","Zeige diese Nachricht" do
        puts opts
        exit
    end
end.parse!
puts usage+"\n\n" if ARGV.empty?

mass = {
  :e  =>   0.000549,  :H  =>   1.007825,  :D  =>   2.014102,
  :T  =>   3.016049,  :He =>   4.002603,  :Li =>   7.016004,
  :Be =>   9.012182,  :B  =>  11.009305,  :C  =>  12.000000,
  :N  =>  14.003074,  :O  =>  15.994915,  :F  =>  18.998403,
  :Ne =>  19.992440,  :Na =>  22.989770,  :Mg =>  23.985042,
  :Al =>  26.981538,  :Si =>  27.976927,  :P  =>  30.973762,
  :S  =>  31.972071,  :Cl =>  34.968853,  :Ar =>  39.962383,
  :Br =>  78.918338,
  :Au => 196.966552
 #:Cl =>  36.965903, #:Ar =>  35.967546, #:Ar =>  37.962732,
 #:S  =>  32.971458, #:S  =>  33.967867, #:S  =>  35.967081,
 #:Si =>  28.976495, #:Si =>  29.973770, #:Mg =>  24.985837,
 #:Mg =>  25.982593, #:Ne =>  20.993847, #:Ne =>  21.991386,
 #:O  =>  16.999132, #:O  =>  17.999160, #:N  =>  15.000109,
 #:C  =>  13.003355, #:C  =>  14.003242, #:B  =>  10.012937,
 #:Li =>   6.015122, #:He =>   3.016029, nicht implementiert
}
storage = Hash.new(0)
def debug help, var
    if $DEBUG then print string+": ";p var end
end

ARGV.each do |formel|
    storage = Hash.new(0)
    debug "Formel", formel
    storage = yamsp formel.dup
    break unless storage
    # Vergleiche mit mass
    sum = options[:neutral] ? 0 : -mass[:e]
    if storage.empty?
        printf "Summenformel %s ist nicht korrekt!\n", formel;next 
    end
    storage.each do |key,value|
        if mass[key]
            sum += value*mass[key] 
        else # kümmert sich um 'neue' Elemente
            puts "Das Element #{key.to_s} ist nicht bekannt"
            print "relative Atommasse von #{key.to_s} ist: "
            cmass = STDIN.gets.chomp.to_f # nur wegen ARGV
            sum += cmass
        end
    end 
    # Ausgabe der Masse
    unless options[:verbose]
        printf "Die angegebene Summenformel %s wurde wie folgt "+
            "zerlegt:\n", formel
        storage.each { |k,v| printf "%ix%s, ", v, k }
    else
        storage each { |k,v| printf "Element %3s mit der Masse "+
            "%6.6fu ist %3i mal in %s enthalten\n", 
            k, mass[k], v, formel }
    end
    pformel = options[:neutral] ? formel : "["+formel+"]+"
    printf "\nDie monoisotopische Verbindung %s wiegt "+
        "\e[1m%.6f\e[22mu\n", pformel, sum
    # Wenn die IM spezifiziert ist
    case options[:method]
    when "ESI"
        puts "Folgende Quasimolekülionen können im Sprektrum "+
            "gefunden werden:\n"
        {
            "[M+H]+" => sum+mass[:H], "[M+Na]+" => sum+mass[:Na],
            "[2M+H]+" => 2*sum+mass[:H], "[2M+Na]+" => 2*sum+mass[:Na], 
            "[3M+H]+" => 3*sum+mass[:H], "[3M+Na]+" => 3*sum+mass[:Na], 
            "[3M+2H]2+" => (3*sum+2*mass[:H]-mass[:e])/2.0, 
            "[3M+2Na]2+" => (3*sum+2*mass[:Na]-mass[:e])/2.0
        }.each { |q,qmass| printf "%12s : %.6fu\n", q, qmass}
    when "FAB" 
        puts "Folgende Quasimolekülionen können im Sprektrum "+
            "gefunden werden:\n"
        {
            "[M+H]+" => sum+mass[:H], "[M+Na]+" => sum+mass[:Na],
            "[2M+H]+" => 2*sum+mass[:H], "[2M+Na]+" => 2*sum+mass[:Na], 
            "[3M+H]+" => 3*sum+mass[:H], "[3M+Na]+" => 3*sum+mass[:Na], 
            "[3M+2H]2+" => (3*sum+2*mass[:H]-mass[:e])/2.0, 
            "[3M+2Na]2+" => (3*sum+2*mass[:Na]-mass[:e])/2.0
        }.each { |q,qmass| printf "%12s : %.6fu\n", q, qmass}
    when "MALDI"
        puts "Folgende Quasimolekülionen können im Sprektrum "+
            "gefunden werden:\n"
        {
            "[M+H]+" => sum+mass[:H], "[M+Na]+" => sum+mass[:Na],
            "[2M+H]+" => 2*sum+mass[:H], "[2M+Na]+" => 2*sum+mass[:Na], 
            "[3M+H]+" => 3*sum+mass[:H], "[3M+Na]+" => 3*sum+mass[:Na], 
            "[3M+2H]2+" => (3*sum+2*mass[:H]-mass[:e])/2.0, 
            "[3M+2Na]2+" => (3*sum+2*mass[:Na]-mass[:e])/2.0
        }.each { |q,qmass| printf "%12s : %.6fu\n", q, qmass}
    when "EI" 
        {
            "[M-CO]+" => sum-mass[:C]-mass[:O], 
            "[M-C2H2]+" => sum-2*mass[:C]-2*mass[:H]
        }.each { |q,qmass| printf "%12s : %.6fu\n", q, qmass}
    else
        puts "Die Ioniersungsmethode #{options[:method]} ist "+
            "nicht implementiert." if options[:method]
    end
end

#EOF
