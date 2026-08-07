# Based on bira theme

setopt prompt_subst

() {

local PR_USER PR_USER_OP PR_PROMPT PR_HOST

# Check the UID
if [[ $UID -ne 0 ]]; then # normal user
  PR_USER='%F{5}%n%f'
  PR_USER_OP='%F{5}%#%f'
  PR_PROMPT='%B%F{magenta}›%f%F{blue}›%f%F{154}›%f❯%b '
else # root
  PR_USER='%F{red}%n%f'
  PR_USER_OP='%F{red}%#%f'
  PR_PROMPT='%F{red}➤ %f'
fi

# Check if we are on SSH or not
if [[ -n "$SSH_CLIENT"  ||  -n "$SSH2_CLIENT" ]]; then
  PR_HOST='%F{yellow}%M%f' # SSH
else
  PR_HOST='%F{53}%m%f' # no SSH
fi


local return_code="%(?..%F{red}%? ↵%f)"

local user_host="%B${PR_USER}%b%F{8}@%B${PR_HOST}%b"
local current_dir="%F{8}› %f%F{4}%~%f"
local git_branch='$(git_prompt_info)'
local venv_prompt='$(virtualenv_prompt_info)' 

PROMPT="%F{8}[%f${venv_prompt}${user_host}%F{8}]%f ${current_dir} \$(ruby_prompt_info) ${git_branch}
%F{8}%f$PR_PROMPT"
RPROMPT="${return_code}"
# %B%F{magenta}❱%f%F{blue}❯%f%F{154}᚛%f ››%b 

ZSH_THEME_GIT_PROMPT_PREFIX="%F{154}‹"
ZSH_THEME_GIT_PROMPT_SUFFIX="› %f"
ZSH_THEME_RUBY_PROMPT_PREFIX="%F{red}‹"
ZSH_THEME_RUBY_PROMPT_SUFFIX="›%f"
ZSH_THEME_VIRTUALENV_PREFIX="%F{red}("
ZSH_THEME_VIRTUALENV_SUFFIX=")%f "

}
