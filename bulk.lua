local M = {}

local patterns = {
  ore = {
    -- generic
    "crushed",
    "dust",
    "nugget",
    "ore",
    "pebble",
    "powder",
    "rock",
    "sand",
    "slag",
    -- angelsrefining
    "^geode%-",
    -- angelssmelting
    "^processed%-",
    -- angelspetrochem
    "^solid%-",
    -- pyrawores
    "^(low%-|high%-)grade%-",
    "^reduced%-",
    "^sintered%-",
    "%-rejects$",
    -- pyalienlife
    "biomass",
    "%-seeds",
    "%-spore",
    "%-leaves$",
  },
  plates = {
    "plate",
    "ingot",
  }
}

-- bulk items that don't fit the above patterns
local items = {
  -- base
  "coal", "landfill", "plastic-bar", "stone", "sulfur",
  -- bobores
  "quartz",
  -- bobplates
  "carbon", "salt", "lithium-chloride", "lithium-perchlorate",
  "sodium-hydroxide", "calcium-chloride", "lead-oxide", "alumina",
  "tungsten-oxide", "silicon-nitride", "cobalt-oxide", "silicon-carbide",
  "silver-nitrate", "silver-oxide",
  -- hardCrafting
  "dirt",
  -- Krastorio
  "enriched-copper", "enriched-iron", "imersite", "k-coke", "k-lithium",
  "k-lithium-chloride", "k-quartz", "k-raw-chunk", "k-silicon",
  "k-tantalum", "k-titanium", "menarite", "raw-imersite", "raw-menarite",
  "raw-minerals", "steel-billet",
  -- Krastorio2
  "raw-rare-metals",
  -- omnimatter
  "omnite",
  -- pycoalprocessing
  "active-carbon", "ash", "bonemeal", "borax", "boron-trioxide",
  "calcium-carbide", "coal-briquette", "coarse", "coke", "dry-ralesia",
  "fawogae", "fawogae-substrate", "gravel", "iron-oxide", "lime", "limestone",
  "lithium-peroxide", "niobium-concentrate", "niobium-oxide", "organics",
  "ppd", "ralesias", "raw-borax", "rich-clay", "soil",
  "zinc-chloride",
  -- pyrawores
  "ammonium-chloride", "clean-nexelit", "coarse-coal", "concentrated-ti",
  "concentrated-zinc", "crystalized-sodium-aluminate",
  "gold-concentrate", "gold-precipitate", "gold-precipitate-2",
  "high-chromite", "high-tin-concentrate", "high-tin-mix",
  "iron-concentrate", "p2s5", "processed-chromite", "purified-gold",
  "purified-quartz", "purified-zinc", "pyrite", "raw-coal", "redhot-coke",
  "salt", "sl-concentrate", "sodium-aluminate", "sodium-bisulfate",
  "sodium-carbonate", "sodium-hydroxide", "sodium-sulfate", "sponge-iron",
  "starch", "tin-concentrate", "ti-residue", "unslimed-iron", "yellow-cake",
  -- pyfusionenergy
  "calcinates", "boron-carbide",
  -- pypetroleumhandling
  "carbon-black", "guar", "soot",
  -- pyhightech
  "cadaveric-arum", "clay", "moondrop", "urea", "ree-concentrate", "reo",
  "phenol", "raw-fiber", "lithium-niobate",
  -- pyalienlife
  "bonemeal", "bones", "cellulose", "chitin", "cobalt-extract",
  "cobalt-fluoride", "dried-grod", "grod", "lignin", "manure",
  "moondrop-diesel", "moondrop-fueloil", "moondrop-gas", "moondrop-kerosene",
  "moss", "rennea", "saps", "sea-sponge", "seaweed", "shell", "sporopollenin",
  "sugar", "yaedols", "nisi", "sic", "green-sic",
}

for i, item in ipairs(items) do
  items[item] = true
  items[i] = nil
end

-- runtime variables

local allowed_items_setting = settings.global["railloader-allowed-items"].value

local function item_matches_patterns(item_name, group)
  for _, pat in ipairs(patterns[group]) do
    if string.find(item_name, pat) then
      return true
    end
  end
  return false
end

local acceptable_item_cache = {}

local function is_acceptable_item(item_name)
  if allowed_items_setting == "any" then
    return true
  end

  local from_cache = acceptable_item_cache[item_name]
  if from_cache ~= nil then
    return from_cache
  end
  acceptable_item_cache[item_name] = items[item_name] or
    item_matches_patterns(item_name, "ore") or
    (allowed_items_setting == "ore, plates" and item_matches_patterns(item_name, "plates"))
  return acceptable_item_cache[item_name]
end

function M.acceptable_items(inventory, limit)
  local out = {}
  for name in pairs(inventory.get_contents()) do
    if is_acceptable_item(name) then
      out[#out+1] = name
      if #out >= limit then
        return out
      end
    end
  end
  return out
end

function M.on_setting_changed()
  allowed_items_setting = settings.global["railloader-allowed-items"].value
  acceptable_item_cache = {}
end

return M
