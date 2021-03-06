-- Returns 1 if replublished, -1 if the id was no longer claimed, or 0 if already published.

-- KEYS:
--  (1) publishedReduceZKey
--  (2) claimedReduceHKey
--  (3) claimStampsHKey
--  (4) notifyReducedLKey
--  (5) payloadsReduceHKey

-- ARGS:
--  (1) claimStamp
--  (2) reduceId
--  (3) reducePayload

if redis.call('hget', KEYS[3], ARGV[2]) ~= ARGV[1] then return -1; end

local weight = redis.call('hget', KEYS[2], ARGV[2]);
redis.call('hdel', KEYS[2], ARGV[2]);
redis.call('hdel', KEYS[3], ARGV[2]);
local published = redis.call('zadd', KEYS[1], 'NX', weight, ARGV[2]);

if published > 0 then
   if KEYS[5] then
      redis.call('hset', KEYS[5], ARGV[2], ARGV[3]);
   end

   if weight == 0 then
      redis.call('lpush', KEYS[4], ARGV[2]);
   end
end

return published;
