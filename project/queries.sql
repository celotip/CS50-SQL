-- Typical SQL queries users will run on this database
-- Add users
INSERT INTO "users" ("name") VALUES ('marcel');
INSERT INTO "users" ("name") VALUES ('theo');
INSERT INTO "users" ("name") VALUES ('ivan');

-- Add groups
INSERT INTO "groups" ("name") VALUES ('balibalibali');

-- Add group_members
INSERT INTO "group_members" ("member_id", "group_id") SELECT "users"."id", "groups"."id" FROM "users", "groups" WHERE "users"."name" = 'marcel' AND "groups"."name" = 'balibalibali';
INSERT INTO "group_members" ("member_id", "group_id") SELECT "users"."id", "groups"."id" FROM "users", "groups" WHERE "users"."name" = 'theo' AND "groups"."name" = 'balibalibali';
INSERT INTO "group_members" ("member_id", "group_id") SELECT "users"."id", "groups"."id" FROM "users", "groups" WHERE "users"."name" = 'ivan' AND "groups"."name" = 'balibalibali';

-- Add transactions
INSERT INTO "transactions" ("user_id", "group_id", "amount", "name") SELECT "users"."id", "groups"."id", 100000, 'lunch' FROM "users", "groups" WHERE "users"."name" = 'marcel' AND "groups"."name" = 'balibalibali';
INSERT INTO "transactions" ("user_id", "group_id", "amount", "name") SELECT "users"."id", "groups"."id", 200000, 'dinner' FROM "users", "groups" WHERE "users"."name" = 'marcel' AND "groups"."name" = 'balibalibali';

-- Add pays
INSERT INTO "pays" ("payer_id", "payee_id", "amount", "group_id") SELECT a."id", b."id", 10000, "groups"."id" FROM 
(SELECT "id" FROM "users" WHERE "name" = 'theo') a,
(SELECT "id" FROM "users" WHERE "name" = 'marcel') b,
"groups" WHERE "groups"."name" = 'balibalibali';

-- View total_owe(user, to_user, group)
SELECT total_owe('theo', 'marcel', 'balibalibali');

-- View group members
SELECT * FROM "balibalibali_group_members";

-- View all pays in the group
SELECT * FROM "balibalibali_pays";

-- View all transactions in the group
SELECT * FROM "balibalibali_transactions";