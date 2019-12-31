# LibThreatClassic2 [!["Open Issues"](https://img.shields.io/github/issues-raw/dfherr/LibThreatClassic2.svg)](https://github.com/dfherr/LibThreatClassic2/issues)

Successor project for [https://github.com/EsreverWoW/LibThreatClassic](https://github.com/EsreverWoW/LibThreatClassic)

The latest version of this library will always be available through the addon [ThreatClassic2](https://github.com/dfherr/ThreatClassic2)

## How to use

To provide Threat data to other players just include and load the lib as part of your addon.

To start using the lib to display threat data get the latest revision from LibStub and get the UnitThreatSituation:

```
local ThreatLib = LibStub:GetLibrary("LibThreatClassic2")

local _UnitThreatSituation = function (unit, mob)
    return ThreatLib:UnitThreatSituation (unit, mob)
end

local _UnitDetailedThreatSituation = function (unit, mob)
    return ThreatLib:UnitDetailedThreatSituation (unit, mob)
end
```


## Added fixes

* Fixed LibStub versioning system (automatically use newest version if multiple LibThreatClassic2 minor versions are available)
* fix Execute threat multiplier for Warriors
* fix Revenge rank 5 bonus threat
* fix Maul threat multiplier for Druids
* Druid Feral instincts fixed
* Warrior defiance 3% instead of 5% per talent point
* SPELL_HEAL / overheal and absorb handling
* Fixed Instance group distribution errors
* Onyxia boss module
* Ragnaros boss module
* Paladin blessings

## TODO

* Improved voidwalker talent
* ...


## License

[LGPL-2.1](LICENSE)

Copyright (c) 2019 Dennis-Florian Herr

LibThreatClassic2 incorporates work covered by the following copyright holders and permission notice:

Copyright (C) 2019 Alexander Burt (Es / EsreverWoW)
Copyright (C) 2007 Chris Heald and the Threat-1.0/Threat-2.0 teams

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
