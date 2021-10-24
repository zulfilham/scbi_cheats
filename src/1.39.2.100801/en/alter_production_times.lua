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
      root_pointer_names = {"items"},
      pointer_names = {[5] = "production_times"},
      value_type = gg.TYPE_DWORD,
      memory_regions = gg.REGION_C_ALLOC | gg.REGION_C_HEAP,
      count_offsets = {},
      show_help = true,
      version_name = "1.39.2.100801",
      version_code = 1039002
   };
   menus = {
      main = {
         {"ALTER PRODUCTION TIMES", "OPEN GAMEGUARDIAN", "EXIT"}, {"🌕   ALTER PRODUCTION TIMES", "🌕   OPEN GAMEGUARDIAN", "🌕   EXIT"},
         prompt = "Choose menu: "
      }
   };

   for key, menu in pairs(menus) do
      menus[key].handler = true;
      menus[key].run = true;
      menus[key].count = #menu[1];
   end;

   if current_informations.x64 then
      informations.address_type = gg.TYPE_QWORD;
      informations.offsets = {production_time = {0x64}};
      root_pointers = {items = {constant_value = -113243136, address_pattern = "1FC"}};
      parent_pointers = {items = {count = 55}};
      pointers = {production_times = {position = 18, count = 103}};
   else
      informations.address_type = gg.TYPE_DWORD;
      informations.offsets = {production_time = {0x40}};
      root_pointers = {items = {constant_value = -443547632, address_pattern = "930"}};
      parent_pointers = {items = {count = 55}};
      pointers = {production_times = {position = 17, count = 103}};
   end;

   for key, offset in pairs(informations.offsets) do
      informations.count_offsets[key] = #offset;
   end;

   data = {
      is_cached = {
         alter_production_times = false
      },
      items = {
         root_pointer = {}, parent_pointers = {}, pointers = {
            production_times = {}
         }
      },
      production_times = {default_values = {}, current_values = {}}
   };
   cache = {filename = gg.CACHE_DIR .. "/.script_cache"};
   load_cache_data();
   messages = {
      positive = {"OK", "GOT IT"},
      items = {
         search_toast = "Finding items root pointer...",
         ambiguous_constant_value = "Warning: Items root pointer is ambiguous, %d found",
         root_pointer_not_found = "Error: Items root pointer was not found",
         parent_pointers_not_found = "Error: Items parent pointers were not found",
         pointers_not_found = {
            production_times = "Error: Production times pointers were not found"
         }
      },
      production_times_altered = "Succeeded to alter production times values",
      production_times_altered_already = "You have already altered production times values",
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

function copy_values(values)
   local results = {};

   for i, value in ipairs(values) do
      results[i] = {};

      for key, attribute in pairs(value) do
         results[i][key] = attribute;
      end;
   end;
   return results;
end;

function find_production_times()
   find_pointers(informations.root_pointer_names[1], informations.pointer_names[5]);
   
   for i, pointer in ipairs(data[informations.root_pointer_names[1]].pointers[informations.pointer_names[5]]) do
      data.production_times.current_values[i] = {address = pointer.address + informations.offsets.production_time[1], flags = informations.value_type};
   end;
   data.production_times.current_values = gg.getValues(data.production_times.current_values);
   data.production_times.default_values = copy_values(data.production_times.current_values);
end;

function main_menu()
   gg.setValues(data.production_times.default_values);

   if type(cache.data.alter_production_times) ~= "table" then
      cache.data.alter_production_times = {};
   end;

   local choices = {};
   local default_choice = nil;

   if math.type(cache.data.alter_production_times.main_menu) == "integer" then
      if cache.data.alter_production_times.main_menu >= 1 and cache.data.alter_production_times.main_menu <= menus.main.count then
         default_choice = cache.data.alter_production_times.main_menu;
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
         if choice == 1 then
            menus.main.run = false;
         end;
         cache.data.alter_production_times.main_menu = choice;
         save_cache_data();
      end;
   else
      menus.main.run = false;
      gg.setValues(data.production_times.current_values);
   end;
   return choice;
end;

function alter_production_times(value)
   local message, fast;

   if not data.is_cached.alter_production_times then
      cache_results();
      find_production_times();
      data.is_cached.alter_production_times = true;
      load_results();
      message = messages.production_times_altered;
      fast = false;
   else
      message = messages.production_times_altered_already;
      fast = true;
   end;

   for i, production_times in ipairs(data.production_times.current_values) do
      production_times.value = value;
   end;
   gg.setValues(data.production_times.current_values);
   gg.toast(message, fast);
end;

function openGameGuardianUi()
   gg.setVisible(true);
   gg.showUiButton();

   if informations.show_help and data[informations.root_pointer_names[1]].pointers[informations.pointer_names[5]][1] then
      gg.alert(messages.show_help, messages.positive[2]);
      informations.show_help = false;
   end;

   local run = true;

   while run do
      gg.setValues(data.production_times.default_values);

      while gg.isVisible() do
         if gg.isClickedUiButton() then
            gg.hideUiButton();
            gg.setVisible(false);
            run = false;
            break;
         end;
      end;
      gg.setValues(data.production_times.current_values);
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
            alter_production_times(0);
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
