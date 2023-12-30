-- Schema of the database

CREATE TABLE "users" (
    "id" SERIAL,
    "name" VARCHAR(32) NOT NULL UNIQUE,
    PRIMARY KEY("id")
);

CREATE TABLE "groups" (
    "id" SERIAL,
    "name" VARCHAR(32) NOT NULL UNIQUE,
    PRIMARY KEY("id"),
);

CREATE TABLE "group_members" (
    "id" SERIAL,
    "member_id" INT,
    "group_id" INT,
    PRIMARY KEY("id"),
    FOREIGN KEY("member_id") REFERENCES "users"("id"),
    FOREIGN KEY("group_id") REFERENCES "groups"("id")
);

CREATE TABLE "transactions" (
    "id" SERIAL,
    "user_id" INT,
    "group_id" INT,
    "name" TEXT NOT NULL,
    "amount" INT NOT NULL,
    "timestamp" TIMESTAMP DEFAULT now(),
    PRIMARY KEY("id"),
    FOREIGN KEY("user_id") REFERENCES "users"("id"),
    FOREIGN KEY("group_id") REFERENCES "groups"("id")
);

CREATE TABLE "pays" (
    "id" SERIAL,
    "payer_id" INT,
    "payee_id" INT,
    "group_id" INT,
    "amount" INT NOT NULL,
    "timestamp" TIMESTAMP DEFAULT now(),
    PRIMARY KEY("id"),
    FOREIGN KEY("payer_id") REFERENCES "users"("id"),
    FOREIGN KEY("payee_id") REFERENCES "users"("id"),
    FOREIGN KEY("group_id") REFERENCES "groups"("id")
);

CREATE VIEW "balibalibali_group_members" AS
SELECT "users"."name" FROM "group_members", "groups", "users", (SELECT "id" FROM "groups" WHERE "name" = 'balibalibali') g WHERE "users"."id" = "member_id" AND "group_id" = g."id";

CREATE VIEW "balibalibali_pays" AS
SELECT x."name" AS "payer", y."name" AS "payee", "amount", "timestamp" FROM "pays", (SELECT "users"."id", "name" FROM "users", "pays" WHERE "payer_id" = "users"."id") x, (SELECT "users"."id", "name" FROM "users", "pays" WHERE "payee_id" = "users"."id") y, (SELECT "id" FROM "groups" WHERE "name" = 'balibalibali') g WHERE x."id" = "payer_id" AND y."id" = "payee_id" AND "group_id" = g."id";

CREATE VIEW "balibalibali_transactions" AS
SELECT "users"."name", "amount", "transactions"."name" AS "transaction", "timestamp" FROM "transactions", "users", (SELECT "id" FROM "groups" WHERE "name" = 'balibalibali') x WHERE "user_id" = "users"."id" AND "group_id" = x."id";

CREATE OR REPLACE FUNCTION total_members(g TEXT)
RETURNS integer AS $$
BEGIN
    RETURN (SELECT COUNT(*) FROM "groups", "group_members" WHERE "groups"."id" = "group_id" AND "name" = g);
END; $$
LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION total_owe(n TEXT, t TEXT, g TEXT)
RETURNS integer AS $$
BEGIN
    RETURN (SELECT COALESCE(SUM("amount"), 0) FROM "transactions", "users", "groups" WHERE "users"."id" = "user_id" AND "groups"."name" = g AND "groups"."id" = "group_id" AND "users"."name" = t) / total_members(g) -
    (SELECT COALESCE(SUM("amount"), 0) FROM "transactions", "users", "groups" WHERE "users"."id" = "user_id" AND "groups"."name" = g AND "groups"."id" = "group_id" AND "users"."name" = n) / total_members(g) -
    (SELECT COALESCE(SUM("amount"), 0) FROM "pays", "users", "groups", (SELECT "id" FROM "users" WHERE "name" = t) x WHERE "users"."id" = "payer_id" AND "groups"."name" = g AND "groups"."id" = "group_id" AND "users"."name" = n AND "payee_id" = x."id") +
    (SELECT COALESCE(SUM("amount"), 0) FROM "pays", "users", "groups", (SELECT "id" FROM "users" WHERE "name" = n) x WHERE "users"."id" = "payer_id" AND "groups"."name" = g AND "groups"."id" = "group_id" AND "users"."name" = t AND "payee_id" = x."id");
END; $$
LANGUAGE plpgsql;

CREATE INDEX "group_name" on "groups" ("id", "name");
CREATE INDEX "user_name" on "users" ("name");
CREATE INDEX "user_transaction" on "transactions" ("user_id", "group_id");
CREATE INDEX "user_payment" on "pays" ("payer_id", "payee_id", "group_id");
CREATE INDEX "user_payer" on "pays" ("payer_id");
CREATE INDEX "user_payee" on "pays" ("payee_id");

GRANT SELECT ON balibalibali_group_members TO celotip;
GRANT SELECT ON balibalibali_pays TO celotip;
GRANT SELECT ON balibalibali_transactions TO celotip;
GRANT SELECT, INSERT ON ALL TABLES IN SCHEMA "public" TO celotip;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO celotip;



