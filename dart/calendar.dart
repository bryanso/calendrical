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
