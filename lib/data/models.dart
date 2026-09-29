/// Typed content models. JSON keys match assets/content/*.json (schema_version 1).
class Condition {
  Condition.fromJson(Map<String, Object?> j)
      : id = j['id'] as String,
        letter = j['letter'] as String,
        name = j['name'] as String,
        slug = j['slug'] as String,
        category = j['category'] as String,
        short = j['short'] as String,
        overview = j['overview'] as String,
        symptoms = _strList(j['symptoms']),
        lessCommon = _strList(j['less_common']),
        causes = _strList(j['causes']),
        risks = _strList(j['risks']),
        care = j['care'] as String,
        redFlags = _strList(j['red_flags']),
        diagnosis = j['diagnosis'] as String,
        management = j['management'] as String,
        ayurveda = j['ayurveda'] as String,
        herbIds = _strList(j['herbs']),
        evidence = j['evidence'] as String,
        evidenceNote = j['evidence_note'] as String,
        safety = j['safety'] as String,
        contra = _strList(j['contra']),
        interactions = j['interactions'] as String,
        pregnancy = j['pregnancy'] as String,
        children = j['children'] as String,
        elderly = j['elderly'] as String,
        relatedConditions = _strList(j['related_conditions']),
        relatedSymptoms = _strList(j['related_symptoms']),
        keywords = _strList(j['keywords']),
        reviewed = j['last_reviewed'] as String,
        version = j['version'] as String,
        dietYes = _strList(j['diet_yes']),
        dietNo = _strList(j['diet_no']),
        image = (j['image'] as String?) ?? '',
        imageCredit = (j['image_credit'] as String?) ?? '',
        sources = (j['sources'] as List)
            .map((s) => SourceRef((s as List)[0] as String, (s)[1] as String))
            .toList();

  final String id, letter, name, slug, category, short, overview;
  final List<String> symptoms, lessCommon, causes, risks;
  final String care;
  final List<String> redFlags;
  final String diagnosis, management, ayurveda;
  final List<String> herbIds;
  final String evidence, evidenceNote, safety;
  final List<String> contra;
  final String interactions, pregnancy, children, elderly;
  final List<String> relatedConditions, relatedSymptoms, keywords;
  final String reviewed, version;
  final List<String> dietYes, dietNo;
  final String image, imageCredit;
  final List<SourceRef> sources;

  static List<String> _strList(Object? v) =>
      ((v as List?) ?? []).map((e) => e.toString()).toList();
}

class SourceRef {
  const SourceRef(this.org, this.url);
  final String org, url;
}

class Herb {
  Herb.fromJson(Map<String, Object?> j)
      : id = j['id'] as String,
        name = j['name'] as String,
        scientific = j['scientific'] as String,
        alt = j['alt'] as String,
        desc = j['desc'] as String,
        traditional = j['traditional'] as String,
        research = j['research'] as String,
        evidence = j['evidence'] as String,
        forms = j['forms'] as String,
        safety = j['safety'] as String,
        contra = _strList(j['contra']),
        interactions = j['interactions'] as String,
        pregnancy = j['pregnancy'] as String,
        children = j['children'] as String,
        reviewed = j['reviewed'] as String,
        version = j['version'] as String;

  final String id, name, scientific, alt, desc, traditional, research;
  final String evidence, forms, safety;
  final List<String> contra;
  final String interactions, pregnancy, children, reviewed, version;

  static List<String> _strList(Object? v) {
    if (v is String) return [v];
    return ((v as List?) ?? []).map((e) => e.toString()).toList();
  }
}

class Product {
  Product.fromJson(Map<String, Object?> j)
      : pid = j['pid'] as String,
        name = j['name'] as String,
        brand = j['brand'] as String,
        desc = j['desc'] as String,
        merchant = j['merchant'] as String,
        country = j['country'] as String,
        currency = j['currency'] as String,
        url = j['url'] as String,
        herb = (j['herb'] as String?) ?? '',
        condIds =
            ((j['conds'] as List?) ?? []).map((e) => e.toString()).toList(),
        evidence = j['evidence'] as String,
        notes = (j['notes'] as String?) ?? '';

  final String pid, name, brand, desc, merchant, country, currency, url;
  final String herb;
  final List<String> condIds;
  final String evidence, notes;
}
