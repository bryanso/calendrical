//
// Adapted from Calendrical Calculations: The Ultimate Edition
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
num sum_if(num Function(int) f, bool Function(int) p, int k) {
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
num multiply_if(num Function(int) f, bool Function(int) p, int k) {
  int i = k;
  num result = 1;
  while (p(i)) {
    result *= f(i);
    i = i + 1;
  }
  return result;
}

//
// 1.32
// MIN search searches for the smallest d in the sequence d0, d0+1, ...
// such that the condition p holds true for d.  The caller must make
// sure this function will terminate for some d.  Return d.
//
int min_search(bool Function(int) p, int d0) {
  while (!p(d0)) {
    d0++;
  }
  return d0;
}

//
// 1.33
// MAX search is the compliment of MIN search.  It returns d such
// that p(d0), p(d0+1), ... p(d) are true but the next one p(d+1) is
// false.  Return d.  If p(d0) is already false, return d0-1.
// The caller must make sure this function will terminate.
//
int max_search(bool Function(int) p, int d0) {
  while (p(d0)) {
    d0++;
  }
  return d0 - 1;
}

//
// 1.34
// This ia generic binary search algorithm that can be adapted to perform
// any searches for answers to some increasing function.
//
// Supposed we want to find x where some function f(x) = y
//
// q(l, u) is an accuracy test, e.g. u - l < 0.0001
// [a, b] is the initial guess interval
// p is a boolean test function that is false within the range [a, x) and
// turns true in the range [x, b]
//
// E.g., To use it to find x that satisifies f(x) = y where f is an
// increasing function and x has accuracy to 4 decimal digits and
// x is known to be between [0, 1] can be:
//
// min_binary_search(
//    function (l, u) { (u - l) < 0.0001 },
//    0,
//    1,
//    function (x) { f(x) >= y }
// )
//
num min_binary_search(
    bool Function(num, num) q, num a, num b, bool Function(num) p) {
  num x = (a + b) / 2; // mid-point
  if (q(a, b)) {
    return x;
  } else {
    return p(x) ? min_binary_search(q, a, x, p) : min_binary_search(q, x, b, p);
  }
}

//
// 1.37
//
List<int> list_of_fixed_from_moments(List<num> l) =>
    l.map(fixed_from_moment).toList();

//
// 1.40
//
// To collect all occurrence of events, such as holidays, in an interval time,
// like a Gregorian year, we write a generic function to find the first occurrence on
// or after a given moment of the p-th moment in a c-day cycle, 0 <= p < c, and then
// recursively find the remaining occurrences:
//
// positions-in-range(p, c, d, [a .. b)) ::=
//     {}                                                 // if  date >= b
//     {date} || positions-in-range(p, c, d, [a+c .. b))  // otherwise
//
// where date = (p - d) mod [a .. a+c)                    // mod2
//
List<num> positions_in_range(num p, num c, num d, num a, num b) {
  num date = mod2(p - d, a, a + c);
  if (date >= b) {
    return [];
  } else {
    return [date] + positions_in_range(p, c, d, a + c, b);
  }
}

//
// 1.41
// Evaluate mixed-radix number
//
// a = { a0 a1 a2 ... an }
//
// written in base
//
// b = { b1 b2 ... bk } || { bk+1 bk+2 ... bn }   // starting from bk+1 it's decimal places
//
// Notice length of b is one less than length of a.
//
num radix(List<num> a, List<num> b, List<num> d) {
  if (a.isEmpty) {
    return 0;
  }

  int n = a.length - 1;
  num result = a[n--]; // Start backwards

  // Decimal places need division
  for (int k = d.length - 1; k >= 0; k--, n--) {
    result = a[n] + result / d[k];
  }

  num factor = 1;
  // Start multiplicative bases
  for (int k = b.length - 1; k >= 0; k--, n--) {
    factor *= b[k];
    result += a[n] * factor;
  }

  // Test cases
  // ♠ radix({0 4 48 0}, {}, {24, 60, 60})
  // 0.19999999999999998
  // ♠ radix({4 1 12 44 2.88} {7} {24 60 60})
  // 29.53058888888889

  return result;
}

//
// 1.42 (Reverse of 1.41)
//
List<num> radix2(num x, List<num> b, List<num> d) {
  List<num> a = [];
  num factor = 1;

  for (int k = 0; k < d.length; k++) {
    factor *= d[k];
    num t = (k == d.length - 1)
        ? mod(x * factor, d[k])
        : mod((x * factor).floor(), d[k]);
    a.add(t);
  }

  factor = 1;
  for (int k = b.length - 1; k >= 0; k--) {
    num t = mod((x / factor).floor(), b[k]);
    a.insert(0, t);
    factor *= b[k];
  }

  // a0
  a.insert(0, (x / factor).floor());
  return a;
}

//
// 1.43
//
// Definition in the book is incorrect.  The following should be the
// corrected version.  But it's more readable to use the 3rd ed. formula.
//
// function time_from_clock(hms) {
//    radix({0} & hms, {}, {24, 60, 60})
// }
//
// Formula from 3rd edition
//
num time_from_clock(List<num> hms) {
  num h = hms[0];
  num m = hms[1];
  num s = hms[2];
  return (h + (m + s / 60) / 60) / 24;
}

//
// 1.44
//
// Formula from 3rd edition
//
// function clock_from_moment(t) {
//     variable h, m, s
//     variable time = time_from_moment(t)
//     h = floor(time * 24)
//     m = floor(mod(time * 24 * 60, 60))
//     s = mod(time * 24 * 60 * 60, 60)
//     {h m s}
// }
//
List<num> clock_from_moment(num t) {
  var l = radix2(t, [], [24, 60, 60]);
  return l.skip(1).toList();
}

//
// 1.45
//
List<num> angle_from_degrees(num a) {
  List<num> dms = radix2(a.abs(), [], [60, 60]);
  if (a < 0) {
    dms[0] = -dms[0];
    dms[1] = -dms[1];
    dms[2] = -dms[2];
  }
  return dms;
}

num test_identical(num x) => x;

bool test_lessthaneleven(int x) => x < 11;

bool test_pi(num x) {
  return x >= 3.1415926538;
}

bool test_accuracy(num l, num u) {
  return (u - l) < 0.0001;
}

main() {
  print("Test");
  num result = sum_if(test_identical, test_lessthaneleven, 0);
  print(result);
  print(min_binary_search(test_accuracy, 0, 10, test_pi));
  print(radix([4, 1, 12, 44, 2.88], [7], [24, 60, 60]));
  print(radix([0, 4, 48, 0], [], [24, 60, 60]));
  print(radix2(0.2, [], [24, 60, 60]));
  print(radix2(29.53058888888889, [7], [24, 60, 60]));
}
