(defn read-file [fname]
  (clojure.string/split-lines (slurp fname)))

(defn travel [state step]
  (let [[pos depth aim] state
        [dir x] (clojure.string/split step #"\s+")
        x (Integer. x)]
    (case dir
      "forward" [(+ pos x) (+ depth (* aim x)) aim]
      "down" [pos depth (+ aim x)]
      "up" [pos depth (- aim x)])))

(defn main []
  (let [input (read-file "input.txt")]
    (let [[pos depth] (reduce travel [0 0 0] input)]
      (println (* pos depth)))))

(main)
