fun main() {
    for (i in 1..5) {
        println("Hello, World!")
        Thread.sleep(5_000)
        if (i == 3) {
            throw Exception("ERROR")
        }
    }
}

main()