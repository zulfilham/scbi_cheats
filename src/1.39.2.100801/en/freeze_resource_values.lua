function initialization()
   USE_ORIGIN_PACKAGE = nil;
   USE_CLONING_PACKAGE = nil;
   USE_UNAUTHORIZED_PACKAGE = nil;
   USE_ORIGIN_VERSION = nil;
   USE_HIGHER_VERSION = nil;
   USE_UNAUTHORIZED_VERSION = nil;
   USE_NO_PROCCESS = nil;

   current_informations = gg.getTargetInfo();
   informations = {
      root_pointer_names = {[2] = "resources"},
      value_type = gg.TYPE_DWORD,
      memory_regions = gg.REGION_C_ALLOC | gg.REGION_C_HEAP,
      count_resource_values = {in_total = 8, per_value = 4},
      count_offsets = {},
      show_help = true,
      version_name = "1.38.0.99752",
      version_code = 1039002
   };
   menus = {
      main = {
         {"FREEZE RESOURCE VALUES", "OPEN GAMEGUARDIAN", "EXIT"}, {"🌕   FREEZE RESOURCE VALUES", "🌕   OPEN GAMEGUARDIAN", "🌕   EXIT"},
         prompt = "Choose menu: "
      },
      freeze_resource_values = {
         {"EXPERIENCE", "SIMOLEON", "SIMCASH", "GOLDEN KEY", "PLATINUM KEY", "VU POINT", "NEOSIMOLEON", "WAR SIMOLEON", "BACK"},
         prompt = "Choose resource values you want to freeze: "
      }
   };

   for key, menu in pairs(menus) do
      menus[key].handler = true;
      menus[key].run = true;
      menus[key].count = #menu[1];
   end;

   if current_informations.x64 then
      informations.address_type = gg.TYPE_QWORD;
      informations.offsets = {resource_values = {0x58, 0x5c, 0x60, 0x64, 0x140, 0x144, 0x148, 0x14c, 0x150, 0x154, 0x158, 0x15c, 0x160, 0x164, 0x168, 0x16c, 0x180, 0x184, 0x188, 0x18c, 0x170, 0x174, 0x178, 0x17c, 0x190, 0x194, 0x198, 0x19c, 0x1a0, 0x1a4, 0x1a8, 0x1ac}};
      root_pointers = {resources = {constant_value = -1447275533, address_pattern = "5F8"}};
      parent_pointers = {resources = {count = 1}};
      pointers = {resources = {position = 1, count = 1}};
   else
      informations.address_type = gg.TYPE_DWORD;
      informations.offsets = {resource_values = {0x40, 0x44, 0x48, 0x4c, 0xc0, 0xc4, 0xc8, 0xcc, 0xd0, 0xd4, 0xd8, 0xdc, 0xe0, 0xe4, 0xe8, 0xec, 0x100, 0x104, 0x108, 0x10c, 0xf0, 0xf4, 0xf8, 0xfc, 0x110, 0x114, 0x118, 0x11c, 0x120, 0x124, 0x128, 0x12c}};
      root_pointers = {resources = {constant_value = -442551240, address_pattern = "188"}};
      parent_pointers = {resources = {count = 1}};
      pointers = {resources = {position = 1, count = 1}};
   end;

   for key, offset in pairs(informations.offsets) do
      informations.count_offsets[key] = #offset;
   end;

   data = {
      is_cached = {
         freeze_resource_values = false
      },
      resources = {
         root_pointer = {}, parent_pointers = {}, pointers = {}
      },
      resource_values = {}
   };
   cache = {filename = gg.CACHE_DIR .. "/.script_cache"};
   load_cache_data();
   messages = {
      positive = {"OK", "GOT IT"},
      resources = {
         search_toast = "Finding resources root pointer...",
         ambiguous_constant_value = "Warning: Resources root pointer is ambiguous, %d found",
         root_pointer_not_found = "Error: Resources root pointer was not found",
         parent_pointers_not_found = "Error: Resources parent pointer was not found",
         pointers_not_found = {
            "Error: Resources pointer was not found"
         }
      },
      no_options_chosen = "Warning: You must choose at least 1 option",
      resource_values_frozen = "Succeeded to freeze resource values",
      resource_values_frozen_already = "You have already frozen resource values",
      file_permission_denied = "Error: Cannot access file '" .. cache.filename .. "': Permission denied",
      show_help = "Notice: You are opening GameGuardian user interface. You can do anything here. When you are finished, you can go back by simply clicking on the Sx button (on upper left of the screen)",
      use_unauthorized_package = "Error: The script can only be run on SimCity BuildIt application",
      use_higher_version = "Warning: You are using SimCity by version " .. current_informations.versionName .. ".\nHowever the script run stably on SimCity " .. informations.version_name .. ", it is possible an error will occur if you keep continuing",
      use_unauthorized_version = "Error: The script can only be run on SimCity version " .. informations.version_name .. " or later",
      use_no_process = "Error: No process chosen",
      exit_code_zero = "Script ended"
   };
end;

function new_search(text, flag, encrypted, sign, memoryFrom, memoryTo, limit)
   if flag == nil then flag = gg.TYPE_AUTO; end;
   if encrypted == nil then encrypted = false; end;
   if sign == nil then sign = gg.SIGN_EQUAL; end;
   if memoryFrom == nil then memoryFrom = 0; end;
   if memoryTo == nil then memoryTo = -1; end;
   if limit == nil then limit = 0; end;

   gg.setVisible(false);
   gg.clearResults();
   gg.searchNumber(text, flag, encrypted, sign, memoryFrom, memoryTo, limit);
end;

function get_results(maxCount, skip, addressMin, addressMax, valueMin, valueMax, flag, fractional, pointer)
   if maxCount == nil then maxCount = gg.getResultsCount(); end;
   if skip == nil then skip = 0; end;

   local results = gg.getResults(maxCount, skip, addressMin, addressMax, valueMin, valueMax, flag, fractional, pointer);
   gg.clearResults();
   return results;
end;

function cache_results()
   cache.results = get_results();
end;

function load_results()
   gg.loadResults(cache.results);
   cache.results = nil;
end;

function file_write(filename, content, append)
   if append == nil then append = false; end;
   local mode = not append and "w" or "a";
   local file_handler = io.open(filename, mode);

   if file_handler then
      file_handler:write(content);
      file_handler:close();
   else
      gg.alert(messages.file_permission_denied, messages.positive[1]);
      os.exit(1);
   end;
end;

function serialize(lua_table)
   local i, results = 1, {};

   for key, value in pairs(lua_table) do
      if key == i then
         key = "";
      elseif type(key) == "string" then
         key = "[" .. string.format("%q", key) .. "]=";
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

function load_cache_data()
   local file_handler = loadfile(cache.filename);
   local is_succeeded, results = pcall(file_handler);
   cache.data = {};

   if is_succeeded and type(results) == "table" then
      cache.data = results;
   end;
end;

function save_cache_data()
   file_write(cache.filename, "return " .. serialize(cache.data));
end;

function identify_root_pointer(value, name)
   new_search(value.address, informations.address_type);
   local count_parent_pointers = gg.getResultsCount();

   if count_parent_pointers == parent_pointers[name].count then
      local parent_pointers = get_results();
      new_search(parent_pointers[count_parent_pointers].address, informations.address_type);

      if gg.getResultsCount() > 0 then
         data[name].root_pointer = value;
         data[name].parent_pointers = parent_pointers;
         local pointers = get_results();

         if name ~= "items" then
            data[name].pointers = pointers;
         else
            data[name].pointers.war_cards = pointers;
         end;
         return true;
      end;
   end;
   return false;
end;

function find_root_pointer(name)
   if not data[name].root_pointer.address then
      gg.toast(messages[name].search_toast, true);
      new_search(root_pointers[name].constant_value, informations.value_type);
      gg.refineAddress(root_pointers[name].address_pattern);
      local results = {};
      local count_results = gg.getResultsCount();

      if count_results >= 1 then
         results = get_results();
         if type(cache.data[name]) ~= "table" then cache.data[name] = {}; end;

         if count_results == 1 then
            data[name].root_pointer = results[1];
            cache.data[name].position = 1;
         else
            local root_pointer_not_found = true;

            if math.type(cache.data[name].position) == "integer" then
               local root_pointer_position = cache.data[name].position;

               if root_pointer_position >= 1 and root_pointer_position <= count_results then
                  if identify_root_pointer(results[root_pointer_position], name) then
                     root_pointer_not_found = false;
                  else
                     results[root_pointer_position] = nil;
                  end;
               end;
            end;

            if root_pointer_not_found then
               gg.alert(string.format(messages[name].ambiguous_constant_value, count_results), messages.positive[1]);

               for i, root_pointer in pairs(results) do
                  if identify_root_pointer(root_pointer, name) then
                     root_pointer_not_found = false;
                     cache.data[name].position = i;
                     break;
                  end;
               end;

               if root_pointer_not_found then
                  gg.clearResults();
                  gg.alert(messages[name].root_pointer_not_found, messages.positive[1]);
                  os.exit(2);
               end;
            end;
         end;
         save_cache_data();
      else
         gg.alert(messages[name].root_pointer_not_found, messages.positive[1]);
         os.exit(1);
      end;
   end;
end;

function find_parent_pointers(name)
   find_root_pointer(name);

   if not data[name].parent_pointers[1] then
      new_search(data[name].root_pointer.address, informations.address_type);

      if gg.getResultsCount() == parent_pointers[name].count then
         data[name].parent_pointers = get_results();
      else
         gg.clearResults();
         gg.alert(messages[name].parent_pointers_not_found, messages.positive[1]);
         os.exit(1);
      end;
   end;
end;

function find_pointers(root_pointer_name, name)
   find_parent_pointers(root_pointer_name);
   if name == nil then name = 1; end;
   local is_items_pointer = name ~= 1;

   if is_items_pointer and not data[root_pointer_name].pointers[name][1] or not data[root_pointer_name].pointers[name] then
      local position = is_items_pointer and pointers[name].position or pointers[root_pointer_name].position;
      new_search(data[root_pointer_name].parent_pointers[position].address, informations.address_type);

      if gg.getResultsCount() > 0 then
         local results = get_results();

         if is_items_pointer then
            data[root_pointer_name].pointers[name] = results;
         else
            data[root_pointer_name].pointers = results;
         end;
      else
         gg.clearResults();
         gg.alert(messages[root_pointer_name].pointers_not_found[name]);
         os.exit(1);
      end;
   end;
end;

function count(table)
   local count_table = 0;

   for i in pairs(table) do
      count_table = count_table + 1;
   end;
   return count_table;
end;

function toboolean(table)
   local results = {};

   for i in pairs(table) do
      if table[i] then
         results[i] = true;
      else
         results[i] = false;
      end;
   end;
   return results;
end;

function is_new_option(previous_options, current_options, count_options)
   previous_options[count_options] = nil;
   current_options[count_options] = nil;
   local count_previous_options = count(previous_options);
   local count_current_options = count(current_options);

   if count_previous_options == count_current_options then
      for previous_option in pairs(previous_options) do
         if not current_options[previous_option] then
            return true;
         end;
      end;
      return false;
   else
      return true;
   end;
end;

function main_menu()
   gg.removeListItems(data.resource_values);

   if type(cache.data.freeze_resource_values) ~= "table" then
      cache.data.freeze_resource_values = {};
   end;

   local choices = {};
   local default_choice = nil;

   if math.type(cache.data.freeze_resource_values.main_menu) == "integer" then
      if cache.data.freeze_resource_values.main_menu >= 1 and cache.data.freeze_resource_values.main_menu <= menus.main.count then
         default_choice = cache.data.freeze_resource_values.main_menu;
      end;
   end;

   if default_choice then
      choices = menus.main[1];
   else
      choices = menus.main[2];
   end;

   local choice = gg.choice(choices, default_choice, menus.main.prompt);

   if choice then
      menus.main.run = true;

      if choice < menus.main.count then
         menus.freeze_resource_values.handler = true;
         menus.freeze_resource_values.run = true;
         cache.data.freeze_resource_values.main_menu = choice;
         save_cache_data();
      end;
   else
      menus.main.run = false;
      gg.addListItems(data.resource_values);
   end;
   return choice;
end;

function menu()
   gg.removeListItems(data.resource_values);

   if type(cache.data.freeze_resource_values.menu) ~= "table" then
      cache.data.freeze_resource_values.menu = {};
   end;

   local default_choices = toboolean(cache.data.freeze_resource_values.menu);
   menus.freeze_resource_values.previous_choices = default_choices;
   local choices = gg.multiChoice(menus.freeze_resource_values[1], default_choices, menus.freeze_resource_values.prompt);
   menus.freeze_resource_values.run = false;

   if choices then
      local count_choices = count(choices);

      if count_choices > 0 then
         if choices[menus.freeze_resource_values.count] then
            menus.freeze_resource_values.handler = false;
            menus.main.run = true;
         end;

         if not choices[menus.freeze_resource_values.count] or count_choices > 1 then
            for i = 1, menus.freeze_resource_values.count, 1 do
               if choices[i] then
                  cache.data.freeze_resource_values.menu[i] = true;
               else
                  cache.data.freeze_resource_values.menu[i] = nil;
               end;
            end;
            save_cache_data();
         else
            cache.data.freeze_resource_values.menu = {};
         end;
      else
         menus.freeze_resource_values.run = true;
      end;
   else
      gg.addListItems(data.resource_values);
   end;
   return choices;
end;

function freeze_resource_values(choices)
   if choices then
      local count_choices = count(choices);

      if count_choices > 0 then
         local no_back_button = not choices[menus.freeze_resource_values.count];
         local more_than_one = count_choices > 1;

         if not data.is_cached.freeze_resource_values and (no_back_button or more_than_one) then
            cache_results();
            find_pointers(informations.root_pointer_names[2]);
            data.is_cached.freeze_resource_values = true;
            load_results();
            gg.toast(messages.resource_values_frozen, false);
         else
            if no_back_button then
               if menus.freeze_resource_values.previous_choices[menus.freeze_resource_values.count] or is_new_option(menus.freeze_resource_values.previous_choices, choices, menus.freeze_resource_values.count) then
                  gg.toast(messages.resource_values_frozen, true);
               else
                  gg.toast(messages.resource_values_frozen_already, true);
               end;
            elseif more_than_one then
               if is_new_option(menus.freeze_resource_values.previous_choices, choices, menus.freeze_resource_values.count) then
                  gg.toast(messages.resource_values_frozen, true);
               end;
            end;
         end;

         data.resource_values = {};

         for i = 1, informations.count_resource_values.in_total, 1 do
            if choices[i] then
               local offset_start = (i - 1) * informations.count_resource_values.per_value + 1;
               local offset_ended = i * informations.count_resource_values.per_value;

               for i = offset_start, offset_ended, 1 do
                  data.resource_values[i] = {address = data[informations.root_pointer_names[2]].pointers[1].address + informations.offsets.resource_values[i], flags = informations.value_type};
               end;
            end;
         end;

         data.resource_values = gg.getValues(data.resource_values);

         for i, resource_value in pairs(data.resource_values) do
            resource_value.freeze = true;
         end;
         gg.addListItems(data.resource_values);
      else
         gg.toast(messages.no_options_chosen);
      end;
   end;
end;

function openGameGuardianUi()
   gg.setVisible(true);
   gg.showUiButton();

   if informations.show_help and data[informations.root_pointer_names[2]].pointers[1] then
      gg.alert(messages.show_help, messages.positive[2]);
      informations.show_help = false;
   end;

   local run = true;

   while run do
      gg.removeListItems(data.resource_values);

      while gg.isVisible() do
         if gg.isClickedUiButton() then
            gg.hideUiButton();
            gg.setVisible(false);
            run = false;
            break;
         end;
      end;
      gg.addListItems(data.resource_values);
      while run and not gg.isVisible() do end;
   end;
end;

function execute()
   gg.setVisible(false);
   gg.setRanges(informations.memory_regions);

   while menus.main.handler do
      if menus.main.run or gg.isVisible() then
         gg.setVisible(false);
         local choice = main_menu();

         if choice == 1 then
            while menus.freeze_resource_values.handler do
               if menus.freeze_resource_values.run or gg.isVisible() then
                  gg.setVisible(false);
                  local choices = menu();
                  freeze_resource_values(choices);
               end;
            end;
         elseif choice == 2 then
            openGameGuardianUi();
         elseif choice == 3 then
            gg.toast(messages.exit_code_zero, true);
            os.exit();
         end;
      end;
   end;
end;

function verify()
   if current_informations then
      local origin_package = "com.ea.game.simcitymobile_row";
      local cloning_package_pattern = "^com.ea.game.simcitymobile_[%w_][%w_][%w_]$";

      if current_informations.cmdLine == origin_package then
         USE_ORIGIN_PACKAGE = true;
      elseif current_informations.cmdLine:match(cloning_package_pattern) then
         USE_CLONING_PACKAGE = true;
      else
         USE_UNAUTHORIZED_PACKAGE = true;
         return nil;
      end;

      if current_informations.versionCode == informations.version_code then
         USE_ORIGIN_VERSION = true;
      elseif current_informations.versionCode > informations.version_code then
         USE_ORIGIN_VERSION = true;
         USE_HIGHER_VERSION = true;
      else
         USE_UNAUTHORIZED_VERSION = true;
      end;
   else
      USE_NO_PROCCESS = true;
   end;
end;

function main()
   initialization();
   verify();

   if USE_ORIGIN_PACKAGE or USE_CLONING_PACKAGE then
      if USE_ORIGIN_VERSION then
         if USE_HIGHER_VERSION then
            gg.alert(messages.use_higher_version);
         end;
         execute();
      else
         gg.alert(messages.use_unauthorized_version, messages.positive[1]);
         os.exit(1);
      end;
   elseif USE_UNAUTHORIZED_PACKAGE then
      gg.alert(messages.use_unauthorized_package, messages.positive[1]);
      os.exit(1);
   else
      gg.alert(messages.use_no_process, messages.positive[1]);
      os.exit(1);
   end;
end;

main();
