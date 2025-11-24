filter_llama_running() {
	curl -s http://localhost:8080 > /dev/null 2>&1 || red_bold "LLama must be running. You can start it with 'dtools ai start-llama'"
}