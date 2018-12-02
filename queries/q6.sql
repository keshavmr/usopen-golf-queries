/* Use PERCENT_RANK in the query. */
with dy as (
  select
    pl.hnum as holedn,
    pl.ps.Nat as country,
    (pl.ps.FN || " " || pl.ps.LN) as name,
    pl.ps.ID as ID,
    array_length(hps.Sks) as score,
    hpl.hole as `hole`,
    hpl.day as `day`
  from
    (
      select
        meta(usopen).id as hnum,
        ps
      from
        usopen use keys "holes:1:1" unnest Ps as ps
    ) pl
    INNER JOIN (
      select
        TONUMBER(split(meta(usopen).id, ":") [1]) as `hole`,
        TONUMBER(split(meta(usopen).id, ":") [2]) as `day`,
        hps
      from
        usopen unnest Rs as rs unnest rs.Hs as hs unnest hs.HPs as hps
    ) hpl on (pl.ps.ID = hps.ID)
),
dx as (
  select
    d.name,
    sum(case when d.day = 1 then d.score else 0 end) R1,
    sum(case when d.day = 2 then d.score else 0 end) R2,
    sum(case when d.day = 3 then d.score else 0 end) R3,
    sum(case when d.day = 4 then d.score else 0 end) R4,
    sum(d.score) T
  from
    dy as d
  group by
    d.name
  order by
    d.name
)
select
  d2.name,
  d2.R1,
  d2.R2,
  d2.R3,
  d2.R4,
  d2.T,
  (
    case when (CUT = 1000) THEN 0 ELSE (d2.R1 + d2.R2 + d2.R3 + d2.R4 -280) END
  ) as TPar,
  RANK() OVER(
    ORDER BY
      d2.T + CUT
  ) as rankScore,
  PERCENT_RANK() OVER(
    ORDER BY
      d2.T + CUT
  ) as percRank
from
  dx as d2 LET CUT = (
    case when (
      d2.R1 = 0
      OR d2.R2 = 0
      OR d2.R3 = 0
      OR d2.R4 = 0
    ) THEN 1000 ELSE 0 END
  )
ORDER BY
  rankScore

