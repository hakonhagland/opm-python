/*
  Copyright 2024 Equinor ASA.

  This file is part of the Open Porous Media project (OPM).

  OPM is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  OPM is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with OPM.  If not, see <http://www.gnu.org/licenses/>.
*/

#include <cstdlib>

#include <fstream>
#include <locale>

#include <opm/input/eclipse/Generator/KeywordGenerator.hpp>
#include <opm/input/eclipse/Generator/KeywordLoader.hpp>


int main([[maybe_unused]] int argc, char ** argv) {
    const char * keyword_list_file = argv[1];
    const char * save_file_name = argv[2];

    std::vector<std::string> keyword_list;
    {
        std::string buffer;
        std::ifstream is(keyword_list_file);
        std::getline( is , buffer );
        is.close();

        size_t start = 0;
        while (true) {
            size_t end = buffer.find( ";" , start);
            if (end == std::string::npos) {
                keyword_list.push_back( buffer.substr(start) );
                break;
            }

            keyword_list.push_back( buffer.substr(start, end - start ));
            start = end + 1;
        }
    }
    Opm::KeywordLoader loader( keyword_list, false );
    Opm::KeywordGenerator generator( true );
    generator.updatePybindSource(loader , save_file_name);
}
