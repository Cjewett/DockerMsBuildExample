using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Extensions
{
    public static class StringExtensions
    {
        public static string Randomize(this string str)
        {
            Random random = new Random();
            return new string(str.ToCharArray().OrderBy(s => (random.Next(2) % 2) == 0).ToArray());
        }
    }
}
