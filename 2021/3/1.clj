(defn most-common-bit [numbers pos]
  (let [bits (map #(get % pos) numbers)
        counts (frequencies bits)]
    (if (> (counts \1) (counts \0))
      \1
      \0)))

(defn main []
  (let [input (clojure.string/split-lines (slurp "input.txt"))
        bits (->> (range 12)
                  (map #(most-common-bit input %))
                  (reduce str))
        gamma (Integer/parseInt bits 2)
        epsilon (bit-and-not 2r111111111111 gamma)]
    (println (* gamma epsilon))))

(main)
