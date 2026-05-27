#!/bin/sh
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "?"')
effort=$(jq -r '.effortLevel // "default"' "$HOME/.claude/settings.json" 2>/dev/null)

has_ctx=$(echo "$input" | jq -r '.context_window.current_usage // empty')
if [ -n "$has_ctx" ]; then
  ctx_used=$(echo "$input" | jq -r '((.context_window.current_usage.input_tokens // 0) + (.context_window.current_usage.cache_creation_input_tokens // 0) + (.context_window.current_usage.cache_read_input_tokens // 0))')
  ctx_total=$(echo "$input" | jq -r '.context_window.context_window_size // 0')
  ctx_pct=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
  ctx_used_k=$((ctx_used / 1000))
  ctx_total_k=$((ctx_total / 1000))
  ctx_str=$(printf "%dk/%dk (%.0f%%)" "$ctx_used_k" "$ctx_total_k" "$ctx_pct")
else
  ctx_str="-/-"
fi

has_sess=$(echo "$input" | jq -r '.session_usage // empty')
if [ -n "$has_sess" ]; then
  sess_in=$(echo "$input" | jq -r '.session_usage.input_tokens // 0')
  sess_cache_cr=$(echo "$input" | jq -r '.session_usage.cache_creation_input_tokens // 0')
  sess_cache_rd=$(echo "$input" | jq -r '.session_usage.cache_read_input_tokens // 0')
  sess_out=$(echo "$input" | jq -r '.session_usage.output_tokens // 0')
  sess_in_k=$(( (sess_in + sess_cache_cr + sess_cache_rd) / 1000 ))
  sess_out_k=$((sess_out / 1000))
  sess_str=$(printf "in:%dk out:%dk" "$sess_in_k" "$sess_out_k")
else
  sess_str=""
fi

has_all=$(echo "$input" | jq -r '.all_usage // empty')
if [ -n "$has_all" ]; then
  all_in=$(echo "$input" | jq -r '.all_usage.input_tokens // 0')
  all_cache_cr=$(echo "$input" | jq -r '.all_usage.cache_creation_input_tokens // 0')
  all_cache_rd=$(echo "$input" | jq -r '.all_usage.cache_read_input_tokens // 0')
  all_out=$(echo "$input" | jq -r '.all_usage.output_tokens // 0')
  all_in_k=$(( (all_in + all_cache_cr + all_cache_rd) / 1000 ))
  all_out_k=$((all_out / 1000))
  all_str=$(printf "in:%dk out:%dk" "$all_in_k" "$all_out_k")
else
  all_str=""
fi

five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
five_str=""
if [ -n "$five_pct" ] && [ -n "$five_reset" ]; then
  now=$(date +%s)
  delta=$(( five_reset - now ))
  if [ "$delta" -gt 0 ]; then
    hrs=$(( delta / 3600 ))
    mins=$(( (delta % 3600) / 60 ))
    five_str=$(printf "5h:%.0f%% resets:%dh%dm" "$five_pct" "$hrs" "$mins")
  else
    five_str=$(printf "5h:%.0f%%" "$five_pct")
  fi
fi

seven_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
seven_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')
seven_str=""
if [ -n "$seven_pct" ] && [ -n "$seven_reset" ]; then
  now=$(date +%s)
  delta=$(( seven_reset - now ))
  if [ "$delta" -gt 0 ]; then
    days=$(( delta / 86400 ))
    hrs=$(( (delta % 86400) / 3600 ))
    seven_str=$(printf "7d:%.0f%% resets:%dd%dh" "$seven_pct" "$days" "$hrs")
  else
    seven_str=$(printf "7d:%.0f%%" "$seven_pct")
  fi
fi

line=$(printf "\033[01;35m%s\033[00m | \033[36meffort:%s\033[00m | \033[33mctx:%s\033[00m" \
  "$model" "$effort" "$ctx_str")

[ -n "$sess_str" ]  && line=$(printf "%s | \033[32msess:%s\033[00m"  "$line" "$sess_str")
[ -n "$all_str" ]   && line=$(printf "%s | \033[34mall:%s\033[00m"   "$line" "$all_str")
thinking_enabled=$(echo "$input" | jq -r '.thinking.enabled // empty')
[ "$thinking_enabled" = "true" ] && thinking_str="thinking:on" || thinking_str="thinking:off"

[ -n "$five_str" ]  && line=$(printf "%s | \033[90m%s\033[00m"       "$line" "$five_str")
[ -n "$seven_str" ] && line=$(printf "%s | \033[90m%s\033[00m"       "$line" "$seven_str")
line=$(printf "%s | \033[90m%s\033[00m" "$line" "$thinking_str")

printf "%s" "$line"
