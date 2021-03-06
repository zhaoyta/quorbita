-- Returns 1 if replublished, -1 if the id was no longer claimed, or 0 if already published for each id.

-- KEYS:
--  (1) publishedZKey
--  (2) claimedHKey
--  (3) notifyLKey
--  (4) payloadsHKey

-- ARGS:
--  (1) inverseScore
--  (2 3 ...) id payload

local republished = {};

local i = 2;
local incr = KEYS[4] and 2 or 1;

local j = 1;

while true do

   local id = ARGV[i];
   if id == nil then return republished; end

   if redis.call('hdel', KEYS[2], id) == 0 then
      republished[j] = -1;
   else
      local published = redis.call('zadd', KEYS[1], 'NX', ARGV[1], id);

      if published > 0 then
         if KEYS[4] then
            redis.call('hset', KEYS[4], id, ARGV[i+1]);
         end

         redis.call('lpush', KEYS[3], id);
      end

      republished[j] = published;
   end

   i = i + incr;
   j = j + 1;
end
