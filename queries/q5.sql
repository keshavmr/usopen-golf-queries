/* Create the full scorecard for the leader using the basic shot-by-shot statistics. */

WITH dy AS (
  SELECT
    pl.hnum AS holedn,
    pl.ps.Nat AS country,(pl.ps.FN || " " || pl.ps.LN) AS name,
    pl.ps.ID AS ID,
    array_length(hps.Sks) AS score,
    hpl.hole AS `hole`,
    hpl.day AS `day`,
    hpl.Par AS Par
  FROM
    (
      SELECT
        meta(usopen).id AS hnum,
        ps
      FROM
        usopen USE keys "holes:1:1" unnest Ps AS ps
      WHERE
        ps.LN = "Koepka"
    ) pl
    INNER JOIN (
      SELECT
        TONUMBER(split(meta(usopen).id, ":") [1]) AS `hole`,
        TONUMBER(split(meta(usopen).id, ":") [2]) AS `day`,
        hs.Par,
        hps
      FROM
        usopen unnest Rs AS rs unnest rs.Hs AS hs unnest hs.HPs AS hps
    ) hpl ON (pl.ps.ID = hps.ID)
),
dx AS (
  SELECT
    d.name,
    d.day,
    d.score,
    d.hole,
    d.Par
  FROM
    dy AS d
  ORDER BY
    d.name
),
dz AS (
  SELECT
    d2.day,
    d2.hole,
    d2.score,
    SUM(d2.score) OVER (
      PARTITION BY d2.day
      ORDER BY
        d2.hole
    ) hst,
    d2.Par,
    SUM(d2.Par) OVER (
      PARTITION BY d2.day
      ORDER BY
        d2.hole
    ) hpr
  FROM
    dx AS d2 LET CUT = (
      CASE WHEN (
        d2.R1 = 0
        OR d2.R2 = 0
        OR d2.R3 = 0
        OR d2.R4 = 0
      ) THEN 1000 ELSE 0 END
    )
  ORDER BY
    d2.day,
    d2.hole
)
SELECT
  d3.Par,
  d3.day,
  d3.hole,
  d3.hst,
  d3.score,(d3.hst - d3.hpr) ToPar,
  sum(d3.score) OVER (
    ORDER BY
      d3.day,
      d3.hole
  ) ToTScore,
  count(1) OVER (
    ORDER BY
      d3.day,
      d3.hole
  ) HoleNum
FROM
  dz AS d3
