-- Returns a list indicating if each job was removed (1) or not (0).

-- KEYS:
--  (1) claimedHKey
--  (2) payloadsHKey

-- ARGS:
--  (1) claimedScore
--  (2 ...) id

local removed = {};

local i = 2;

while true do

   local id = ARGV[i];
   if id == nil then return removed; end

   local claimedScore = redis.call('hget', KEYS[1], id);
   if claimedScore == nil or claimedScore ~= ARGV[1] then
      removed[i] = 0;
   else
      redis.call('hdel', KEYS[1], id);
      redis.call('hdel', KEYS[2], id);
      removed[i] = 1;
   end

   i = i + 1;
end
