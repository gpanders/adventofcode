(ns day3-part2
  (:require
    [clojure.string :as str]))

(defn most-common-bit [numbers pos]
  (let [bits (map #(get % pos) numbers)
        counts (frequencies bits)]
    (if (>= (counts \1) (counts \0))
      \1
      \0)))

(defn invert-bit [b]
  (case b
    \0 \1
    \1 \0))

(defn bit-criteria [type]
  (case type
    :oxygen most-common-bit
    :co2 #(invert-bit (apply most-common-bit %&))))

(defn filter-numbers [type numbers pos]
  (let [bit ((bit-criteria type) numbers pos)
        numbers (filter #(= (get % pos) bit) numbers)]
    (if (= (count numbers) 1)
      (first numbers)
      (filter-numbers type numbers (+ pos 1)))))

(defn -main []
  (let [input (str/split-lines (slurp "input.txt"))]
    (println
      (reduce
        *
        (map
          #(Integer/parseInt (filter-numbers % input 0) 2)
          [:oxygen :co2])))))

(-main)
