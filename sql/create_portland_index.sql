drop table if exists portland_index;

with
portland as (
  select
    places.*
  from
    states
  inner join
    places on st_contains(states.geom, places.geom)
  where
    stusps10 = 'OR' and
    namelsad10 = 'Portland city'
),
portland_bgroups as (
  select
    lai.*,
    st_makevalid(st_intersection(lai.geom, portland.geom)) as clipped_geom
  from
    portland
  inner join
    location_affordability_index lai on st_intersects(portland.geom, lai.geom)
)

select * into portland_index from portland_bgroups;

alter table portland_index drop column geom;
alter table portland_index rename column clipped_geom to geom;
alter table portland_index alter column geom type geometry(Geometry, 4326) using st_transform(geom, 4326);
create index portland_lai_idx on portland_index using gist(geom);