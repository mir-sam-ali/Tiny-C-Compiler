int i, space, rows, k = 0;

rows = 10;
for (i = 1; i <= rows; ++i, k = 0)
{
    for (space = 1; space <= rows - i; ++space)
    {
        print("  ");
    }
    while (k != 2 * i - 1)
    {
        print("* ");
        ++k;
    }
    print("\n");
}