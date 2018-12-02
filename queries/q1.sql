/* Create a report of player scores by round and the final total.  */

WITH d AS (
  SELECT
    pl.hnum AS holedn,
    pl.ps.Nat AS country,
    (pl.ps.FN || " " || pl.ps.LN) AS name,
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
        usopen unnest Rs AS rs UNNEST rs.Hs AS hs UNNEST hs.HPs AS hps
    ) hpl ON (pl.ps.ID = hps.ID)
)
SELECT
  d.name,
  SUM(
    CASE WHEN d.day = 1 THEN d.score ELSE 0 END
  ) R1,
  SUM(
    CASE WHEN d.day = 2 THEN d.score ELSE 0 END
  ) R2,
  SUM(
    CASE WHEN d.day = 3 THEN d.score ELSE 0 END
  ) R3,
  SUM(
    CASE WHEN d.day = 4 THEN d.score ELSE 0 END
  ) R4,
  SUM(d.score) T
FROM
  d
GROUP BY
  d.name
ORDER BY
  d.name
