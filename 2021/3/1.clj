(defn most-common-bit [numbers pos]
  (let [bits (map #(get % pos) numbers)
        counts (frequencies bits)]
    (if (> (counts \1) (counts \0))
      \1
      \0)))

(defn bit-array-to-int [array]
  (-> (reduce str array)
      (Integer/parseInt 2)))

(defn invert-bit [b]
  (case b
    \0 \1
    \1 \0))

(defn main []
  (let [input (clojure.string/split-lines (slurp "input.txt"))
        f (partial most-common-bit input)
        gamma-bits (map f (range (count (first input))))
        epsilon-bits (map invert-bit gamma-bits)
        gamma (bit-array-to-int gamma-bits)
        epsilon (bit-array-to-int epsilon-bits)]
    (println (* gamma epsilon))))

(main)
