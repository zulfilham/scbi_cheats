local function load_cache_data()
   local loader = loadfile(cache.filename);
   local succeeds, results = pcall(loader);
   cache.data = {};

   if succeeds and type(results) == "table" then
      cache.data = results;
   end;
end;

local function initialization()
   informations = {
      value_type = gg.TYPE_DWORD,
      memory_regions = gg.REGION_C_ALLOC | gg.REGION_C_HEAP,
      show_help = true,
      is_executed = false
   };
   menus = {
      main = {
         items = {
            "Common Buildings",
            "Cheetah's Epic Buildings",
            "Miscellaneous Hacks",
            "Fast Epic",
            "Exit"
         },
         prompt = "Welcome to SimCity Buildit Hack.  Script by LG Channel",
         count = 5,
         handler = true,
         run = true,
         [1] = {
            items = {
               "Maxis Manor [Wind Power Plant]",
               "Ultimate Mayor Statue [Basic Water Tower]",
               "MaxisMan Statue [Small Sewage Outflow Pipe]",
               "Common Homes L6 [Coal Power Plant]",
               "Tokyo Town Homes L6 [Basic Sewage Outflow Pipe]",
               "Parisian Homes L6 [Small Garbage Dump]",
               "London Town Homes L6 [Garbage Dump]",
               "OMEGA Residential Building L6 [Deluxe Wind Power Plant]",
               "Green Valley Homes L6 [Small Fire Station]",
               "Cactus Canyon Homes L6 [Small Police Station]",
               "Sunny Isles Homes L6 [Small Health Clinic]",
               "Frosty Fjords Homes L6 [Small Fountain Park]",
               "Limestone Cliffs Homes L6 [Modern Art Park]",
               "Old Watermill [Reflecting Pool Park]",
               "Nothern Lights Research Institute L10 [Peaceful Park]",
               "Taxi Stop L10 [Urban Plaza]",
               "Mahjong Hall L10 [Casino City Park]",
               "Tea House L10 [Fish Market]",
               "Back"
            },
            prompt = "Please place the required building in advance and check carefully whether the buildings may have been placed before",
            count = 19,
            handler = true,
            run = true
         },
         [2] = {
            items = {
               "Education Specialization Epic [Garbage Incinerator]",
               "Gambling Specialization Epic [Small Factory]",
               "Entertainment Specialization Epic [Basic Factory]",
               "Transportation Specialization Epic [Basic Fire Station]",
               "Landmarks Specialization Epic [Basic Police Station]",
               "Beach Specialization Epic [Health Clinic]",
               "Mountain Specialization Epic [University Park Cafeteria]",
               "Back"
            },
            prompt = "Please place the required building in advance and check carefully whether the buildings may have been placed before",
            count = 8,
            handler = true,
            run = true
         },
         [3] = {
            items = {
               "Maximum City Storage [Initial City Storage]",
               "Maximum OMEGA Storage [Initial OMEGA Storage]",
               "Maximum NeoBank [Initial NeoBank]",
               "Vu Tower Level 18 [Initial Vu Tower]",
               "Unlock NeoMall under level 30",
               "Lock NeoMall under level 30",
               "Alter Ad Billboard to Spider (Horror Movie Set)",
               "Back"
            },
            prompt = "Choose Hack: ",
            count = 8,
            handler = true,
            run = true
         },
         [4] = {
            items = {
               "Education Fast Epic [Residential Zone]",
               "Gambling Fast Epic [Residential Zone]",
               "Entertainment Fast Epic [Residential Zone]",
               "Transportation Fast Epic [Residential Zone]",
               "Landmarks Fast Epic [Residential Zone]",
               "Beach Fast Epic [Residential Zone]",
               "Mountain Fast Epic [Residential Zone]",
               "Back"
            },
            prompt = "Choose Fast Epic: ",
            count = 8,
            handler = true,
            run = true
         }
      }
   };
   buildings_constants = {
      [1] = {
         {search = 751144117, edit = 925375395},
         {search = 139346164, edit = 2040088750},
         {search = 182280403, edit = -2089966647},
         {search = -1297331478, edit = 1522778650},
         {search = -12118437, edit = 1493262871},
         {search = -741284489, edit = 2050186616},
         {search = -935683329, edit = -1203406301},
         {search = 43959869, edit = -1430868908},
         {search = 583140736, edit = 973877747},
         {search = -150077002, edit = -1528167776},
         {search = -66177429, edit = -1220248775},
         {search = -1672104106, edit = 2038647854},
         {search = 712780976, edit = -46404375},
         {search = -1250093364, edit = 1321420829},
         {search = -958560911, edit = -61527945},
         {search = -958560910, edit = 776814664},
         {search = -383906791, edit = 1225598517},
         {search = -1685111278, edit = -1053961458}
      },
      [2] = {
         {search = -1415031897, edit = -1881032548},
         {search = 612373322, edit = -691412735},
         {search = -1199642511, edit = -447372290},
         {search = 388741896, edit = 1813794920},
         {search = -1397016258, edit = -113962678},
         {search = 1155556851, edit = -1999290445},
         {search = 58778652, edit = 995463179}
      },
      [3] = {
         {search = 1785034572, edit = -1223401048},
         {search = -5428496, edit = -179140214},
         {search = 1148880551, edit = -741647391},
         {search = 2019791904, edit = 1362697172},
         {search = 424671600, edit = 2087261488},
         {search = 2087261488, edit = 424671600},
         {search = 49899925, edit = -1323273224}
      },
      [4] = {
         {search = 1522778645, edit = -1881032548},
         {search = 1522778645, edit = -691412735},
         {search = 1522778645, edit = -447372290},
         {search = 1522778645, edit = 1813794920},
         {search = 1522778645, edit = -113962678},
         {search = 1522778645, edit = -1999290445},
         {search = 1522778645, edit = 995463179}
      }
   };
   cache = {filename = gg.CACHE_DIR .. "/.script_cache"};
   load_cache_data();
   messages = {
      positive = {"OK", "GOT IT"},
      game_reloading_notice = "Notice: The script will alter Buildings constant(s) according to your choice.  Once the value is changed, the in-game buildings will not change immediately.\n\nTherefore, it is IMPORTANT to reload your city so that the in-game buildings reflect it (this action is highly recommended to prevent damage in the game).\n\nFor Example: try visiting another city and then come back to your own city",
      altering_buildings_constants = "Altering Buildings constant(s)...",
      buildings_constants_altered = "Suceeded to alter Buldings constant(s)",
      no_options_chosen = "Warning: You must choose at least 1 option",
      file_permission_denied = "Error: Cannot access file '" .. cache.filename .. "': Permission denied",
      exit_code_zero = "Script ended"
   };
end;

local function new_search(text, type, encrypted, sign, memoryFrom, memoryTo, limit)
   gg.clearResults();
   gg.searchNumber(text, type, encrypted, sign, memoryFrom, memoryTo, limit);
end;

local function get_results(maxCount, skip, addressMin, addressMax, valueMin, valueMax, type, fractional, pointer)
   local results = gg.getResults(maxCount or gg.getResultsCount(), skip, addressMin, addressMax, valueMin, valueMax, type, fractional, pointer);
   gg.clearResults();
   return results;
end;

local function cache_results()
   cache.results = get_results();
end;

local function load_results()
   gg.loadResults(cache.results);
   cache.results = nil;
end;

local function serialize(lua_table)
   local i, results = 1, {};

   for key, value in pairs(lua_table) do
      if key == i then
         key = "";
      elseif type(key) == "string" then
         key = key:match("^[%a_][%w_]*$") and key .. "=" or string.format("[%q]=", key);
      else
         key = "[" .. key .. "]=";
      end;

      if type(value) == "boolean" or type(value) == "number" then
         results[i] = key .. tostring(value);
      elseif type(value) == "string" then
         results[i] = key .. string.format("%q", value);
      elseif type(value) == "table" then
         results[i] = key .. serialize(value);
      end;
      i = i + 1;
   end;
   return "{" .. table.concat(results, ",") .. "}";
end;

local function save_cache_data()
   local file = io.open(cache.filename, "w");

   if file then
      file:write("return ", serialize(cache.data), ";"):close();
   else
      gg.setVisible(true);
      gg.alert(messages.file_permission_denied, messages.positive[1]);
      os.exit(1);
   end;
end;

local function count(table)
   local count_table = 0;

   for i in pairs(table) do
      count_table = count_table + 1;
   end;
   return count_table;
end;

local function main_menu()
   if type(cache.data.main) ~= "table" then
      cache.data.main = {};
   end;

   gg.hideUiButton();
   local choice = gg.choice(menus.main.items, cache.data.main.default or 1, menus.main.prompt);

   if choice then
      menus.main.run = true;

      if choice < menus.main.count then
         cache.data.main.default = choice;
      end;

      if choice < (menus.main.count - 1) then
         menus.main[choice].handler = true;
         menus.main[choice].run = true;
      end;
   else
      menus.main.run = false;
      gg.showUiButton();
   end;
   return choice;
end;

local function secondary_menu(choice)
   if type(cache.data.main[choice]) ~= "table" then
      cache.data.main[choice] = {};
   end;

   gg.hideUiButton();
   local choices = gg.multiChoice(menus.main[choice].items, cache.data.main[choice].defaults, menus.main[choice].prompt);

   if choices then
      menus.main[choice].run = true;
      local count_choices = count(choices);

      if count_choices > 0 then
         if choices[menus.main[choice].count] then
            menus.main[choice].handler = false;
            menus.main.run = true;
         end;

         if count_choices > 1 or not choices[menus.main[choice].count] then
            cache.data.main[choice].defaults = choices;
            menus.main[choice].run = false;
            gg.showUiButton();
         end;
      end;
   else
      menus.main[choice].run = false;
      gg.showUiButton();
   end;
   return choices;
end;

local function fastEpicCheatMenu()
   if type(cache.data.main[4]) ~= "table" then
      cache.data.main[4] = {};
   end;

   gg.hideUiButton();
   local choice = gg.choice(menus.main[4].items, cache.data.main[4].default or 1, menus.main[4].prompt);

   if choice then
      menus.main[4].run = true;

      if choice < menus.main[4].count then
         cache.data.main[4].default = choice;
         menus.main[4].run = false;
         gg.showUiButton();
      else
         menus.main[4].handler = false;
         menus.main.run = true;
      end;
   else
      menus.main[4].run = false;
      gg.showUiButton();
   end;
   return choice;
end;

local function alter_buildings_constants(choice, choices)
   if choices then
      local count_choices = count(choices);

      if count_choices > 0 then
         local no_back_button = not choices[menus.main[choice].count];
         local more_than_one = count_choices > 1;

         if not informations.is_executed and (no_back_button or more_than_one) then
            gg.alert(messages.game_reloading_notice, messages.positive[2]);
            informations.is_executed = true;
         end;

         if no_back_button or more_than_one then
            gg.toast(messages.altering_buildings_constants, true);
            cache_results();

            for user_choice in pairs(choices) do
               if user_choice == menus.main[choice].count then break; end;
               new_search(buildings_constants[choice][user_choice].search, informations.value_type);
               gg.getResults(gg.getResultsCount());
               gg.editAll(buildings_constants[choice][user_choice].edit, informations.value_type);
               gg.clearResults();
            end;
            load_results();
            gg.toast(messages.buildings_constants_altered, true);
         end;
      else
         gg.toast(messages.no_options_chosen, true);
      end;
   end;
end;

local function fast_epic_cheat(user_choice)
   if user_choice and user_choice < menus.main[4].count then
      if not informations.is_executed then
         gg.alert(messages.game_reloading_notice, messages.positive[2]);
         informations.is_executed = true;
      end;

      if informations.default_values then
         gg.setValues(informations.default_values);
      end;
      gg.toast(messages.altering_buildings_constants, true);
      new_search(buildings_constants[4][user_choice].search, informations.value_type);
      informations.default_values = gg.getResults(gg.getResultsCount());
      gg.editAll(buildings_constants[4][user_choice].edit, informations.value_type);
      gg.clearResults();
      gg.toast(messages.buildings_constants_altered, true);
   end;
end;

local function execute()
   gg.showUiButton();
   gg.setRanges(informations.memory_regions);

   while menus.main.handler do
      if menus.main.run or gg.isClickedUiButton() then
         local choice = main_menu();

         if choice and choice >= 1 and choice <= 3 then
            while menus.main[choice].handler do
               if menus.main[choice].run or gg.isClickedUiButton() then
                  local choices = secondary_menu(choice);
                  alter_buildings_constants(choice, choices);
               end;
               gg.sleep(50);
            end;
         elseif choice == 4 then
            while menus.main[4].handler do
               if menus.main[4].run or gg.isClickedUiButton() then
                  local choice = fastEpicCheatMenu();
                  fast_epic_cheat(choice);
               end;
            end;
         elseif choice == 5 then
            if informations.default_values then
               gg.setValues(informations.default_values);
            end;
            save_cache_data();
            gg.setVisible(true);
            gg.toast(messages.exit_code_zero, true);
            os.exit();
         end;
      end;
      gg.sleep(50);
   end;
end;

---------MAIN CODE---------

initialization();
execute();
