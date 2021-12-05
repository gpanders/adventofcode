(defn read-file [fname]
  (clojure.string/split-lines (slurp fname)))

(defn travel [state step]
  (let [[pos depth] state
        [dir x] (clojure.string/split step #"\s+")
        x (Integer. x)]
    (case dir
      "forward" [(+ pos x) depth]
      "down" [pos (+ depth x)]
      "up" [pos (- depth x)])))

(defn main []
  (let [input (read-file "input.txt")]
    (let [[h v] (reduce travel [0 0] input)]
      (println (* h v)))))

(main)
