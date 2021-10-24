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
      pointer_names = {"common_items", "rare_items", "omega_items"},
      value_type = gg.TYPE_DWORD,
      memory_regions = gg.REGION_C_ALLOC | gg.REGION_C_HEAP,
      count_offsets = {},
      show_help = true,
      version_name = "1.39.2.100801",
      version_code = 1039002
   };
   menus = {
      main = {
         {"UBAH SIMCASH INSTAN", "BUKA GAMEGUARDIAN", "EKSIT"}, {"🌕   UBAH SIMCASH INSTAN", "🌕   BUKA GAMEGUARDIAN", "🌕   EKSIT"},
         prompt = "Pilih menu: "
      }
   };

   for key, menu in pairs(menus) do
      menus[key].handler = true;
      menus[key].run = true;
      menus[key].count = #menu[1];
   end;

   if current_informations.x64 then
      informations.address_type = gg.TYPE_QWORD;
      informations.offsets = {instant_simcash = {0x54}};
      root_pointers = {items = {constant_value = -113243136, address_pattern = "1FC"}};
      parent_pointers = {items = {count = 55}};
      pointers = {common_items = {position = 16, count = 112}, rare_items = {position = 28, count = 15}, omega_items = {position = 30, count = 10}};
   else
      informations.address_type = gg.TYPE_DWORD;
      informations.offsets = {instant_simcash = {0x30}};
      root_pointers = {items = {constant_value = -443547632, address_pattern = "930"}};
      parent_pointers = {items = {count = 55}};
      pointers = {common_items = {position = 15, count = 112}, rare_items = {position = 27, count = 15}, omega_items = {position = 29, count = 10}};
   end;

   for key, offset in pairs(informations.offsets) do
      informations.count_offsets[key] = #offset;
   end;

   data = {
      is_cached = {
         alter_instant_simcash = false
      },
      items = {
         root_pointer = {}, parent_pointers = {}, pointers = {
            common_items = {}, rare_items = {}, omega_items = {}
         }
      },
      instant_simcash = {default_values = {}, current_values = {}}
   };
   cache = {filename = gg.CACHE_DIR .. "/.script_cache"};
   load_cache_data();
   messages = {
      positive = {"OKE", "SAYA MENGERTI"},
      items = {
         search_toast = "Mencari petunjuk akar barang...",
         ambiguous_constant_value = "Peringatan: Petunjuk akar barang ambigu, %d ditemukan",
         root_pointer_not_found = "Eror: Petunjuk akar barang tidak ditemukan",
         parent_pointers_not_found = "Eror: Petunjuk induk barang tidak ditemukan",
         pointers_not_found = {
            common_items = "Eror: Petunjuk barang biasa tidak ditemukan",
            rare_items = "Eror: Petunjuk barang langka tidak ditemukan",
            omega_items = "Eror: Petunjuk barang OMEGA tidak ditemukan"
         }
      },
      instant_simcash_altered = "Berhasil mengubah nilai simcash instan",
      instant_simcash_altered_already = "Anda memang sudah mengubah nilai simcash instan",
      file_permission_denied = "Eror: Tidak dapat mengakses berkas '" .. cache.filename .. "': Perizinan ditolak",
      show_help = "Pemberitahuan: Anda sedang membuka antarmuka pengguna GameGuardian. Disini anda bisa melakukan apa saja, setelah selesai anda bisa kembali lagi dengan mengklik tombol Sx (di kiri atas layar)",
      use_unauthorized_package = "Eror: Skrip ini hanya bisa dijalankan pada aplikasi SimCity BuildIt",
      use_higher_version = "Peringatan: Anda sedang menggunakan SimCity versi " .. current_informations.versionName .. ".\nSementara skrip ini berjalan stabil di SimCity versi " .. informations.version_name .. ", ada kemungkinan skrip akan mengalami eror jika dilanjutkan",
      use_unauthorized_version = "Eror: Skrip ini hanya bisa dijalankan pada SimCity versi " .. informations.version_name .. " atau ke atas",
      use_no_process = "Eror: Tidak ada proses yang dipilih",
      exit_code_zero = "Skrip berakhir"
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

function find_instant_simcash()
   local count_instant_simcash = 0;

   for i, pointer_name in ipairs(informations.pointer_names) do
      find_pointers(informations.root_pointer_names[1], pointer_name);

      for j, pointer in ipairs(data[informations.root_pointer_names[1]].pointers[pointer_name]) do
         count_instant_simcash = count_instant_simcash + 1;
         data.instant_simcash.current_values[count_instant_simcash] = {address = pointer.address + informations.offsets.instant_simcash[1], flags = informations.value_type};
      end;
   end;
   data.instant_simcash.current_values = gg.getValues(data.instant_simcash.current_values);
   data.instant_simcash.default_values = copy_values(data.instant_simcash.current_values);
end;

function main_menu()
   gg.setValues(data.instant_simcash.default_values);

   if type(cache.data.alter_instant_simcash) ~= "table" then
      cache.data.alter_instant_simcash = {};
   end;

   local choices = {};
   local default_choice = nil;

   if math.type(cache.data.alter_instant_simcash.main_menu) == "integer" then
      if cache.data.alter_instant_simcash.main_menu >= 1 and cache.data.alter_instant_simcash.main_menu <= menus.main.count then
         default_choice = cache.data.alter_instant_simcash.main_menu;
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
         cache.data.alter_instant_simcash.main_menu = choice;
         save_cache_data();
      end;
   else
      menus.main.run = false;
      gg.setValues(data.instant_simcash.current_values);
   end;
   return choice;
end;

function alter_instant_simcash(value)
   local message, fast;

   if not data.is_cached.alter_instant_simcash then
      cache_results();
      find_instant_simcash();
      data.is_cached.alter_instant_simcash = true;
      load_results();
      message = messages.instant_simcash_altered;
      fast = false;
   else
      message = messages.instant_simcash_altered_already;
      fast = true;
   end;

   for i, instant_simcash in ipairs(data.instant_simcash.current_values) do
      instant_simcash.value = value;
   end;
   gg.setValues(data.instant_simcash.current_values);
   gg.toast(message, fast);
end;

function openGameGuardianUi()
   gg.setVisible(true);
   gg.showUiButton();

   if informations.show_help and data[informations.root_pointer_names[1]].pointers[informations.pointer_names[1]][1] then
      gg.alert(messages.show_help, messages.positive[2]);
      informations.show_help = false;
   end;

   local run = true;

   while run do
      gg.setValues(data.instant_simcash.default_values);

      while gg.isVisible() do
         if gg.isClickedUiButton() then
            gg.hideUiButton();
            gg.setVisible(false);
            run = false;
            break;
         end;
      end;
      gg.setValues(data.instant_simcash.current_values);
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
            alter_instant_simcash(0);
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
