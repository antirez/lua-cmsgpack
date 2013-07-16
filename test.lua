require "cmsgpack"
-- lua_cmsgpack.c lib tests
-- Copyright(C) 2012 Salvatore Sanfilippo, All Rights Reserved.
-- See the copyright notice at the end of lua_cmsgpack.c for more information.

passed = 0
failed = 0

local Chars = {}
for Loop = 0, 255 do
   Chars[Loop+1] = string.char(Loop)
end
local String = table.concat(Chars)

local Built = {['.'] = Chars}

local AddLookup = function(CharSet)
   local Substitute = string.gsub(String, '[^'..CharSet..']', '')
   local Lookup = {}
   for Loop = 1, string.len(Substitute) do
       Lookup[Loop] = string.sub(Substitute, Loop, Loop)
   end
   Built[CharSet] = Lookup

   return Lookup
end

function string.random(Length, CharSet)
   -- Length (number)
   -- CharSet (string, optional); e.g. %l%d for lower case letters and digits

   local CharSet = CharSet or '.'

   if CharSet == '' then
      return ''
   else
      local Result = {}
      local Lookup = Built[CharSet] or AddLookup(CharSet)
      local Range = table.getn(Lookup)

      for Loop = 1,Length do
         Result[Loop] = Lookup[math.random(1, Range)]
      end

      return table.concat(Result)
   end
end

function hex(s)
    local i
    local h = ""

    for i = 1, #s do
        h = h .. string.format("%02x",string.byte(s,i))
    end
    return h
end

function ascii_to_num(c)
    if (c >= string.byte("0") and c <= string.byte("9")) then
        return c - string.byte("0")
    elseif (c >= string.byte("A") and c <= string.byte("F")) then
        return (c - string.byte("A"))+10
    elseif (c >= string.byte("a") and c <= string.byte("f")) then
        return (c - string.byte("a"))+10
    else
        error "Wrong input for ascii to num convertion."
    end
end

function unhex(h)
    local i
    local s = ""
    for i = 1, #h, 2 do
        high = ascii_to_num(string.byte(h,i))
        low = ascii_to_num(string.byte(h,i+1))
        s = s .. string.char((high*16)+low)
    end
    return s
end

function compare_objects(a,b)
    if (type(a) == "table") then
        local count = 0
        for k,v in pairs(a) do
            if not compare_objects(b[k],v) then return false end
            count = count + 1
        end
        -- All the 'a' keys are equal to their 'b' equivalents.
        -- Now we can check if there are extra fields in 'b'.
        for k,v in pairs(b) do count = count - 1 end
        if count == 0 then return true else return false end
    else
        return a == b
    end
end

function test_circular(name,obj)
    io.write("Circular test '",name,"' ...")
    if not compare_objects(obj,cmsgpack.unpack(cmsgpack.pack(obj))) then
        print("ERROR:", obj, cmsgpack.unpack(cmsgpack.pack(obj)))
        failed = failed+1
    else
        print("ok")
        passed = passed+1
    end
end

function test_pack(name,obj,raw)
    io.write("Testing encoder '",name,"' ...")
    if hex(cmsgpack.pack(obj)) ~= raw then
        print("ERROR:", obj, hex(cmsgpack.pack(obj)), raw)
        failed = failed+1
    else
        print("ok")
        passed = passed+1
    end
end

function test_unpack(name,raw,obj)
    io.write("Testing decoder '",name,"' ...")
    if not compare_objects(cmsgpack.unpack(unhex(raw)),obj) then
        print("ERROR:", obj, raw, cmsgpack.unpack(unhex(raw)))
        failed = failed+1
    else
        print("ok")
        passed = passed+1
    end
end

function test_pack_and_unpack(name,obj,raw)
    test_pack(name,obj,raw)
    test_unpack(name,raw,obj)
end

test_circular("positive fixnum",17);
test_circular("negative fixnum",-1);
test_circular("true boolean",true);
test_circular("false boolean",false);
test_circular("float",1.5);
test_circular("positive uint8",101);
test_circular("negative int8",-101);
test_circular("positive uint16",20001);
test_circular("negative int16",-20001);
test_circular("positive uint32",20000001);
test_circular("negative int32",-20000001);
test_circular("positive uint64",200000000001);
test_circular("negative int64",-200000000001);
test_circular("uint8 max",0xff);
test_circular("uint16 max",0xffff);
test_circular("uint32 max",0xffffffff);
test_circular("int8 min",-128);
test_circular("int16 min",-32768);
test_circular("int32 min",-2147483648);
test_circular("nil",nil);
test_circular("fix string","abc");
test_circular("string16","xaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaab");
test_circular("fix array (1)",{1,2,3,"foo"})
test_circular("fix array (2)",{})
test_circular("fix array (3)",{1,{},{}})

gap_array = {1,2,3,4}
gap_array[7] = 2
test_circular("fix array (4)", gap_array)

test_circular("fix map (1)",{a=5,b=10,c="string"})

hash_num = 5
arrary_num = 1000000
large_table = {}
for i = 1, hash_num do
    large_table[string.random(5, "%l%d%u")] = i
end
for i = 1, arrary_num do
    large_table[i] = i + 10000000
end
test_circular("fix large map (2)", large_table)

gap_hash = {1,2,3,4}
gap_hash[7] = 2
gap_hash["hello"] = 4
test_circular("fix map(3)", gap_array)

hash_num = 5
arrary_num = 65530
medium_table = {}
for i = 1, hash_num do
    medium_table[string.random(5, "%l%d%u")] = i
end
for i = 1, arrary_num do
    medium_table[i] = i + 10000000
end
test_circular("fix large map (4)", medium_table)

arrary_num = 1000000
large_array = {}
for i = 1, arrary_num do
    large_array[i] = i + 10000000
end
test_circular("large array", large_array)

-- The following test vectors are taken from the Javascript lib at:
-- https://github.com/cuzic/MessagePack-JS/blob/master/test/test_pack.html

test_pack_and_unpack("positive fixnum",0,"00")
test_pack_and_unpack("negative fixnum",-1,"ff")
test_pack_and_unpack("uint8",255,"ccff")
test_pack_and_unpack("fix raw","a","a161")
test_pack_and_unpack("fix array",{0},"9100")
test_pack_and_unpack("fix map",{a=64},"81a16140")
test_pack_and_unpack("nil",nil,"c0")
test_pack_and_unpack("true",true,"c3")
test_pack_and_unpack("false",false,"c2")
test_pack_and_unpack("double",0.1,"cb3fb999999999999a")
test_pack_and_unpack("uint16",32768,"cd8000")
test_pack_and_unpack("uint32",1048576,"ce00100000")
test_pack_and_unpack("int8",-64,"d0c0")
test_pack_and_unpack("int16",-1024,"d1fc00")
test_pack_and_unpack("int32",-1048576,"d2fff00000")
test_pack_and_unpack("int64",-1099511627776,"d3ffffff0000000000")
test_pack_and_unpack("raw16","                                        ","da002820202020202020202020202020202020202020202020202020202020202020202020202020202020")
test_pack_and_unpack("array 16",{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},"dc001000000000000000000000000000000000")

-- Regression test for issue #4, cyclic references in tables.
function cyclic_refer_test()
    a = {x=nil,y=5}
    b = {x=a}
    a['x'] = b
    cmsgpack.pack(a)
end

if pcall(cyclic_refer_test) then
    print "FAILED: exception no throw"
else
    print "Testing max nesting ...ok"
end
-- test_pack("regression for issue #4",a,"82a17905a17881a17882a17905a17881a17882a17905a17881a17882a17905a17881a178c0")

-- Final report
print()
print("TEST PASSED:",passed)
print("TEST FAILED:",failed)
