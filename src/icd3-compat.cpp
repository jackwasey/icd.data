#include <Rcpp.h>
using namespace Rcpp;

std::vector<std::string> qx  = {"C4A", "D3A", "M1A", "Z3A", "C7A", "C7B"};
std::vector<std::string> qb  = {"C43", "D36", "M09", "Z36", "C75", "C7A"};
std::vector<std::string> qa  = {"C44", "D37", "M10", "Z37", "C7B", "C76"};
std::vector<std::string> qbb = {"C43", "D36", "M09", "Z36", "C75", "C75"};
std::vector<std::string> qaa = {"C44", "D37", "M10", "Z37", "C76", "C76"};

std::pair<bool, bool> icd10cmCompareQuirk(const Rcpp::String &x,
                                          const Rcpp::String &y,
                                          const char *quirk,
                                          const char *beforeQuirk,
                                          const char *afterQuirk,
                                          const char *beforeBeforeQuirk,
                                          const char *afterAfterQuirk) {
  const char *xstr = x.get_cstring();
  const char *ystr = y.get_cstring();
  bool mx          = (x == quirk || strncmp(xstr, quirk, 3) == 0);
  bool my          = (y == quirk || strncmp(ystr, quirk, 3) == 0);
  if (!mx && !my) return std::pair<bool, bool>(false, false);
  if (x == y) return std::pair<bool, bool>(true, false);
  if (mx) {
    if (my) {
      return std::pair<bool, bool>(true, x < y);
    }
    if (strcmp(beforeQuirk, beforeBeforeQuirk)) {
      return icd10cmCompareQuirk(x,
                                 y,
                                 quirk,
                                 beforeBeforeQuirk,
                                 afterQuirk,
                                 beforeBeforeQuirk,
                                 afterAfterQuirk);
    }
    return std::pair<bool, bool>(true, strcmp(beforeQuirk, ystr) < 0);
  }
  if (strcmp(afterQuirk, afterAfterQuirk)) {
    return icd10cmCompareQuirk(x,
                               y,
                               quirk,
                               beforeQuirk,
                               afterAfterQuirk,
                               beforeBeforeQuirk,
                               afterAfterQuirk);
  }
  return std::pair<bool, bool>(true, strcmp(xstr, afterQuirk) < 0);
}

// [[Rcpp::export(icd10cm_compare_rcpp)]]
bool icd10cmCompare(const Rcpp::String x, const Rcpp::String y) {
  const char *xstr = x.get_cstring();
  const char *ystr = y.get_cstring();
  const int i      = strncmp(xstr, ystr, 1);
  // get out quick if first character differs.
  if (i != 0) return i < 0;
  // in flat file, C4A is between 43 and 44. Definitive reference I am using is
  // the flat file with all the codes from CMS.
  std::pair<bool, bool> quirkResult;
  for (std::vector<std::string>::size_type j = 0; j != qa.size(); ++j) {
    quirkResult = icd10cmCompareQuirk(x,
                                      y,
                                      qx[j].c_str(),
                                      qb[j].c_str(),
                                      qa[j].c_str(),
                                      qbb[j].c_str(),
                                      qaa[j].c_str());
    if (quirkResult.first) return quirkResult.second;
  }
  return x < y;
}

// [[Rcpp::export(icd10cm_sort_rcpp)]]
CharacterVector icd10cmSort(const CharacterVector &x) {
  std::vector<std::string> x_ = as<std::vector<std::string> >(x);
  std::sort(x_.begin(), x_.end(), icd10cmCompare);
  return wrap(x_);
}

// [[Rcpp::export(icd10cm_order_rcpp)]]
IntegerVector icd10cmOrder(const CharacterVector &x) {
  // see icd9Order for a different approach
  CharacterVector x_sorted = icd10cmSort(x);
  return match(x, x_sorted);
}

// [[Rcpp::export(icd9_compare_rcpp)]]
bool icd9Compare(std::string a, std::string b) {
  const char *acs = a.c_str();
  const char *bcs = b.c_str();
  // most common is numeric, so deal with that first:
  if (*acs < 'A') return strcmp(acs, bcs) < 0;
  // if the second char is now  a number, then we can immediately return false
  if (*bcs < 'A') return false;
  // V vs E as first or both characters is next
  if (*acs == 'V' && *bcs == 'E') return true;
  if (*acs == 'E' && *bcs == 'V') return false;
  // now cover both V codes or both E codes
  return strcmp(acs, bcs) < 0;
}

typedef std::pair<std::string, std::size_t> pas;

bool icd9ComparePair(pas a, pas b) {
  std::string af = a.first;
  std::string bf = b.first;
  return icd9Compare(af, bf);
}

// add one because R indexes from 1, not 0
inline std::size_t
  getSecondPlusOne(const std::pair<std::string, std::size_t> &p) {
    return p.second + 1;
  }

// [[Rcpp::export(icd9_order_rcpp)]]
std::vector<std::size_t> icd9Order(std::vector<std::string> x) {
  std::vector<std::pair<std::string, std::size_t>> vp;
  std::vector<std::size_t> out;
  out.reserve(x.size());
  vp.reserve(x.size());
  for (std::size_t i = 0; i != x.size(); ++i)
    vp.push_back(std::make_pair(x[i], i));
  std::sort(vp.begin(), vp.end(), icd9ComparePair);
  std::transform(vp.begin(),
                 vp.end(),
                 std::back_inserter(out),
                 getSecondPlusOne);
  return out;
}
