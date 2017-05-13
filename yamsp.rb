#!/usr/bin/env ruby2.1
# YAMSP - YetAnotherMassSpectrometryParser
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

def yamsp mole
    storage = Hash.new(0)
    until mole.empty?
        if /\A[A-Z][a-z]*/.match mole
            atom = $&
           #debug "Atom", atom
            mole = $'
            if /\A\d+/.match $'
                count = $&.to_i
               #debug "Anzahl", count
                mole  = $'
            else
                count = 1
            end
           #debug "Fragment", mole
            storage[atom.to_sym] += count
           #debug "Storage", storage
        else
            return nil unless mole.capitalize!
           #debug "rescue", mole
        end
    end
    storage
end
#EOF
