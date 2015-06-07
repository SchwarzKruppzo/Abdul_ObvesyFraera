local m_tClassFormat = {}
m_tClassFormat["abdul_machete"] = "Machete"
m_tClassFormat["RailCells"] = "Rail Cells"
m_tClassFormat["abdul_railgun"] = "Rail Rifle"
m_tClassFormat["45ACP"] = "Maslinki"
m_tClassFormat["abdul_nubogun"] = "Nubogun"
m_tClassFormat["AK47"] = "Kalash Clip"
m_tClassFormat["abdul_ak47"] = "Kalash"
m_tClassFormat["ShrapBomb"] = "Shrap Bombs"
m_tClassFormat["abdul_maslachesator"] = "Maslachezator"
m_tClassFormat["shotbuck"] = "Buckshot"
m_tClassFormat["abdul_shotgun"] = "Maslobaba"
m_tClassFormat["rockets"] = "Rockets"
m_tClassFormat["abdul_rocketlauncher"] = "Maslorocketnica"
m_tClassFormat["ent_armor"] = "Armor Shard"
m_tClassFormat["ent_armorred"] = "Mega Armor"
m_tClassFormat["ent_armoryellow"] = "Armor"
m_tClassFormat["ent_healthvial"] = "+5 Health"
m_tClassFormat["ent_healthkit"] = "+25 Health"
m_tClassFormat["abdul_claymore"] = "MLG18 Claymore"
m_tClassFormat["claymore"] = "MLG18 Claymore"
m_tClassFormat["abdul_noscoper"] = "420noscoper"
m_tClassFormat["mlg"] = "Homing Bullet"

function ClassToFormat( class )
	return m_tClassFormat[ class ] or "Unknown"
end