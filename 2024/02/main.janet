(defn parse [input]
  (->> input
       (string/trim)
       (peg/match
         ~{:main (any (group :line))
           :line (* (some (* (number :d+) (? " "))) (+ "\n" -1))})))

(def sample (parse (slurp "sample.txt")))
(def input (parse (slurp "input.txt")))

(defn safe? [line]
  (let [diffs (seq [i :range [1 (length line)]]
                (- (line i) (line (dec i))))
        signs-differ (not (= ;(map |(< 0 $) diffs)))
        magnitudes (map |(math/abs $) diffs)]
    (if signs-differ
      false
      (and (<= (max-of magnitudes) 3) (<= 1 (min-of magnitudes))))))

(defn permutations [arr]
  (seq [i :range [0 (length arr)]]
    (tuple/join (tuple/slice arr 0 i) (tuple/slice arr (inc i)))))

(defn part1 [input]
  (length (filter safe? input)))

(defn part2 [input]
  (length (filter |(if (safe? $)
                     true
                     (any? (map safe? (permutations $))))
                  input)))

(assert (= 2 (part1 sample)))
(assert (= 4 (part2 sample)))

(defn main [&]
  (print (part1 input))
  (print (part2 input)))
