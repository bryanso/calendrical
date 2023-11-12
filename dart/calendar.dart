//
// Adapted from Calendrical Calculations by
// Edward M. Reingold and Nachum Dershowitz
//

//
// 1.17
// The book uses a different definition of mod function:
// x mod y ::= x - y * floor(x/y)
//
num mod(num x, num y) => x - y * (x / y).floor();

//
// 1.1 Initial Epoch and Rata Die (fixed date)
//
final Epoch = 0;
num rd(num t) {
  return t - Epoch;
}

final JD_Epoch = rd(-1721424.5); // 1.3 Julian date epoch
final MJD_Epoch = rd(678576); // 1.6 Modified Julian Epoch
final UNIX_Epoch = rd(719163); // 1.9 Unix Epoch

//
// 1.4
//
num moment_from_jd(num jd) => jd + JD_Epoch;

//
// 1.5
//
num jd_from_moment(num t) => t - JD_Epoch;

//
// 1.7
//
num fixed_from_mjd(num mjd) => mjd + MJD_Epoch;

//
// 1.8
//
num mjd_from_fixed(num date) => date - MJD_Epoch;

//
// 1.10
//
num moment_from_unix(int seconds) => UNIX_Epoch + seconds / 24.0 / 60.0 / 60.0;

//
// 1.11
//
num unix_from_moment(num t) => 24 * 60 * 60 * (t - UNIX_Epoch);

//
// 1.12
//
int fixed_from_moment(num t) => t.floor();

//
// 1.13
//
int fixed_from_jd(num jd) => moment_from_jd(jd).floor();

//
// 1.14
//
num jd_from_fixed(num date) => jd_from_moment(date);

//
// 1.18
//
num time_from_moment(num t) => mod(t, 1);

//
// 1.22
//
num gcd(num x, num y) {
  return (y == 0) ? x : gcd(y, mod(x, y));
}

//
// 1.23
//
num lcm(num x, num y) {
  return x * y / gcd(x, y);
}

//
// 1.24
// This is a modified mod typeset as x mod [a .. b) in the book.
//
// x mod [a .. b) ::=
//     x                     if a == b;
//     a + (x-a) mod (b-a)   otherwise
//
num mod2(num x, num a, num b) => (a == b) ? x : a + mod(x - a, b - a);

//
// 1.28
// This is a modified mod typeset as x mod [1 .. b] in the book.
//
// x mod [1 .. b] ::=
//     b                 if x mod b == 0
//     x mod b           otherwise
//
num mod3(num x, num b) {
  num n = mod(x, b);
  return (n == 0) ? b : n;
}

//
// 1.30
// Conditional summation will sum f(i) starting from i = k
// as long as p(i) is true.
//
num sum_if(Function f, Function p, int k) {
  int i = k;
  num result = 0;
  while (p(i)) {
    result += f(i);
    i = i + 1;
  }
  return result;
}

//
// 1.31
// Conditional multiplication analogous to 1.30 above.
// Multiply f(i) as long as p(i) is true.
//
num multiply_if(Function f, Function p, int k) {
  int i = k;
  num result = 1;
  while (p(i)) {
    result *= f(i);
    i = i + 1;
  }
  return result;
}

num test_identical(num x) => x;

bool test_lessthaneleven(int x) => x < 11;

main() {
  print("Test");
  num result = sum_if(test_identical, test_lessthaneleven, 0);
  print(result);
}
