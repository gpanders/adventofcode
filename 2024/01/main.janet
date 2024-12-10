(defn transpose [grid]
  (let [rows (length grid)
        cols (length (grid 0))
        result (array/new-filled cols)]
    (loop [i :range [0 cols]] (put result i (array/new rows)))
    (loop [row :range [0 rows]
           col :range [0 cols]]
      (put (result col) row ((grid row) col)))
    result))

(def input (->> (slurp "input.txt")
                (peg/match
                  ~{:main (any (group :line))
                    :line (* (number :d+) :s+ (number :d+) (+ "\n" -1))})
                (transpose)))

(defn part1 [input]
  (let [first (sorted (input 0))
        second (sorted (input 1))]
    (reduce |(+ $0 (math/abs (- ;$1))) 0 (transpose [first second]))))

(defn part2 [input]
  (def counts @{})
  (each num (input 1)
    (put counts num (+ (get counts num 0) 1)))

  (reduce |(+ $0 (* $1 (get counts $1 0))) 0 (input 0)))

(defn main [&]
  (print (part1 input))
  (print (part2 input)))
