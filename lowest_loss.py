# Lists all directories in the 'out' folder sorted by their loss values (highest to lowest)

from pathlib import Path
import os

def get_loss(dir_path):
    try:
        with open(Path(dir_path) / 'loss.txt', 'r') as f:
            if line := f.readline().strip():
                if line.startswith('Final loss:'):
                    return float(line.split(':')[1].strip())
    except (ValueError, IndexError, FileNotFoundError):
        pass
    return float('inf')

def main():
    if not (out_dir := Path('out')).exists():
        print("Error: 'out' directory not found")
        return

    # Get all directories and their losses, sorted high to low
    dir_losses = [(d.name, get_loss(d)) for d in out_dir.iterdir() 
                  if d.is_dir() and not d.name.startswith('.')]
    dir_losses.sort(key=lambda x: x[1], reverse=True)

    # Print results with clean padding
    max_len = max(len(name) for name, _ in dir_losses)
    for name, loss in dir_losses:
        print(f"{name:<{max_len}} {loss:>10.6f}")

    generate_html_report(dir_losses)

def generate_html_report(dir_losses):
    html_content = """
    <html>
    <head>
        <title>Loss Report</title>
        <link rel="stylesheet" href="https://unpkg.com/sakura.css/css/sakura.css" type="text/css">
        <link rel="stylesheet" href="https://unpkg.com/normalize.css@8.0.1/normalize.css" type="text/css">
    </head>
    <body>
    <h1>Loss Report</h1>
    <table>
        <tr><th>Directory</th><th>Loss</th><th>Model Image</th></tr>
    """

    for name, loss in dir_losses:
        dir_path = os.path.abspath(Path('out') / name)
        img_path = Path('out') / name / 'final_model.png'
        img_tag = f'<img src="{img_path}" alt="Model Image">' if img_path.exists() else 'No Image'
        html_content += f"<tr><td><a href='file://{dir_path}'>{name}</a></td><td>{loss:.6f}</td><td>{img_tag}</td></tr>"

    html_content += """
    </table>
    </body>
    </html>
    """

    with open('loss_report.html', 'w') as f:
        f.write(html_content)

if __name__ == "__main__":
    main()