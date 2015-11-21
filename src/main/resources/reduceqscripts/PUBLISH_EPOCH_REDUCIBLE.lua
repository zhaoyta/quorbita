-- PUBLISH_EPOCH_REDUCIBLE

-- KEYS:
--  (1) publishedZKey
--  (2) claimedHKey
--  (3) payloadsHKey
--  (4) notifyLKey
--  (5) pendingMappedSKey
--  (6) publishedReduceZKey
--  (7) claimedReduceHKey
--  (8) payloadsReduceHKey

-- ARGS:
--  (1) score
--  (2) reduceWeight
--  (3) reduceId
--  (4) reducePayload
--  (5 6 ...) id payload

local numPublished = 0;
local weight = 0;
local i = 5;

while true do

   local id = ARGV[i];
   if id == nil then break end

   local claimed = redis.call('hexists', KEYS[2], id);

   if claimed == 0 then
      redis.call('hsetnx', KEYS[3], id, ARGV[i+1]);
      redis.call('sadd', KEYS[5], id);

      local added = redis.call('zadd', KEYS[1], 'NX', ARGV[1], id);
      if added > 0 then
         redis.call('lpush', KEYS[4], id);
         numPublished = numPublished + 1;
         weight = weight + ARGV[2]
      end
   end

   i = i + 2;
end

local claimed = redis.call('hexists', KEYS[7], ARGV[3]);
if claimed == 0 then
   redis.call('hsetnx', KEYS[8], ARGV[3], ARGV[4]);
   redis.call('zadd', KEYS[6], weight, ARGV[3]);
else
   redis.call('hincrby', KEYS[7], ARGV[3], weight);
end

return numPublished;