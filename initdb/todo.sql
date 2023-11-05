
create schema api;

create table api.users(
  id serial primary key,
  name  VARCHAR(255),
  email VARCHAR(255) 
);



create role web_anon nologin;
grant usage on schema api to web_anon;
grant select on api.users to web_anon;

create role authenticator noinherit login password 'password';
grant web_anon to authenticator;

create role pippo nologin;
grant pippo to authenticator;

grant usage on schema api to pippo;
grant all on api.users to pippo;
grant usage, select on sequence api. to pippo

