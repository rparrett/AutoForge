# Lists all directories in the 'out' folder sorted by their loss values (highest to lowest)

from pathlib import Path

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

if __name__ == "__main__":
    main()