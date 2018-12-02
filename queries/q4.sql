WITH dy AS (
  SELECT
    pl.hnum AS holedn,
    pl.ps.Nat AS country,(pl.ps.FN || " " || pl.ps.LN) AS name,
    pl.ps.ID AS ID,
    array_length(hps.Sks) AS score,
    hpl.hole AS `hole`,
    hpl.day AS `day`
  FROM
    (
      SELECT
        meta(usopen).id AS hnum,
        ps
      FROM
        usopen USE keys "holes:1:1" unnest Ps AS ps
    ) pl
    INNER JOIN (
      SELECT
        TONUMBER(split(meta(usopen).id, ":") [1]) AS `hole`,
        TONUMBER(split(meta(usopen).id, ":") [2]) AS `day`,
        hps
      FROM
        usopen unnest Rs AS rs unnest rs.Hs AS hs unnest hs.HPs AS hps
    ) hpl ON (pl.ps.ID = hps.ID)
),
dx AS (
  SELECT
    d.name,
    sum(
      CASE WHEN d.day = 1 THEN d.score ELSE 0 END
    ) R1,
    sum(
      CASE WHEN d.day = 2 THEN d.score ELSE 0 END
    ) R2,
    sum(
      CASE WHEN d.day = 3 THEN d.score ELSE 0 END
    ) R3,
    sum(
      CASE WHEN d.day = 4 THEN d.score ELSE 0 END
    ) R4,
    sum(d.score) T
  FROM
    dy AS d
  GROUP BY
    d.name
  ORDER BY
    d.name
)
SELECT
  d2.name,
  d2.R1,
  d2.R2,
  d2.R3,
  d2.R4,
  d2.T,
  DENSE_RANK() OVER (
    ORDER BY
      d2.T + CUT
  ) AS rankMoney,
  RANK() OVER (
    ORDER BY
      d2.T + CUT
  ) AS rankFinal,
  RANK() OVER (
    ORDER BY
      d2.R1
  ) AS round1rank,
  RANK() OVER (
    ORDER BY
      d2.R1 + d2.R2
  ) AS round2rank,
  RANK() OVER (
    ORDER BY
      d2.R1 + d2.R2 + d2.R3 + CUT
  ) AS round3rank
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
  rankFinal,
  round1rank,
  round2rank,
  round3rank
