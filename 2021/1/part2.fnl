(fn read-input []
  (icollect [l (io.lines)] (tonumber l)))

(fn main []
  (var increases 0)
  (let [input (read-input)]
    (var last-window (+ (. input 1) (. input 2) (. input 3)))
    (var cur-window 0)
    (for [i 4 (length input)]
      (set cur-window (+ (. input (- i 2))
                         (. input (- i 1))
                         (. input i)))
      (if (> cur-window last-window)
          (set increases (+ increases 1)))
      (set last-window cur-window)))
  (print increases))

(main)
