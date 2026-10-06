import time
from rich.live import Live
from rich.panel import Panel
from master import wow
from master import main


if __name__ == '__main__':
    wow.start()
    main.start()
    with Live(Panel("初始化中..."), refresh_per_second=10) as live:
        i = 0
        while True:
            time.sleep(0.1)
            # 用新的渲染对象替换当前终端显示
            i += 1
            live.update(Panel(f"[bold green]当前步数:[/bold green] {i}/5\n[cyan]状态正常运行中...[/cyan]"))
