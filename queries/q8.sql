/* Ranking using subqueries when RANK() functions are unavailable. */

with dy as (select pl.hnum as holedn,
      pl.ps.Nat as country,
       (pl.ps.FN || " " || pl.ps.LN) as name,
      pl.ps.ID as ID,
      array_length(hps.Sks) as score,
      hpl.hole as `hole`,
      hpl.day as `day`
from
(select meta(usopen).id as hnum, ps from usopen use keys "holes:1:1" unnest Ps as ps)  pl
INNER JOIN
(select TONUMBER(split(meta(usopen).id, ":")[1]) as `hole`,
      TONUMBER(split(meta(usopen).id, ":")[2]) as `day`,
       hps from usopen
unnest Rs as rs unnest rs.Hs as hs unnest hs.HPs as hps)  hpl
on (pl.ps.ID  = hps.ID)),
dx as (
select d.name,
       sum(case when d.day = 1 then d.score else 0 end) R1,
       sum(case when d.day = 2 then d.score else 0 end) R2,
       sum(case when d.day = 3 then d.score else 0 end) R3,
       sum(case when d.day = 4 then d.score else 0 end) R4,
       sum(d.score) T
from dy as d
group by d.name
order by d.name),
dz as (select  d2.*,
       (select raw 1 + COUNT(*) from dx as dr where (dr.R1 + dr.R2) < (d2.R1 + d2.R2))[0] as sql2rank,
       (select raw COUNT(*) from dx as dr where (dr.R1+dr.R2) < (d2.R1 + d2.R2) or
                                   ((dr.R1+dr.R2) =(d2.R1 + d2.R2) and dr.name <= d2.name) )[0] as sql2rownumber,
    (select raw COUNT(distinct (dr.R1+dr.R2)) from dx as dr where (dr.R1+dr.R2) <= (d2.R1 + d2.R2))[0] as sql2denserank
       from dx as d2)
select dz from dz
where dz.sql2rank <= 60
order by dz.sql2rank, dz.sql2rownumber

