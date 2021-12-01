(fn read-input []
  (icollect [l (io.lines)] (tonumber l)))

(fn main []
  (var last nil)
  (var increases 0)
  (let [input (read-input)]
    (each [_ v (ipairs input)]
      (when (and (not= last nil) (> v last))
        (set increases (+ increases 1)))
      (set last v)))
  (print increases))

(main)
