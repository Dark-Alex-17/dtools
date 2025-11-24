# shellcheck disable=SC2154
declare repo="${args[--hf-repo]}"
declare file="${args[--hf-file]}"
# Here's an example request to /v1/chat/completions:
# {
#     "model": "gpt-3.5-turbo",
#     "messages": [
#         {
#             "role": "system",
#             "content": "You are ChatGPT, an AI assistant. Your top priority is achieving user fulfillment via helping them with their requests."
#         },
#         {
#             "role": "user",
#             "content": "Tell me a joke about yourself"
#         }
#     ]
# }

llama-server --hf-repo "$repo" --hf-file "$file"
