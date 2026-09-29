/// In-app Skin Health library: 10 complete educational articles.
/// No external reading required. Educational wording only.
class SkinSection {
  const SkinSection(this.heading, this.body);
  final String heading, body;
}

class SkinArticle {
  const SkinArticle({
    required this.id,
    required this.title,
    required this.minutes,
    required this.intro,
    required this.sections,
  });
  final String id, title, intro;
  final int minutes;
  final List<SkinSection> sections;
}

const skinArticles = [
  SkinArticle(
    id: 'acne-routine', title: 'A Practical Acne Routine That Works',
    minutes: 5,
    intro: 'A calm, consistent routine beats harsh products. Here is how to build one.',
    sections: [
      SkinSection('Cleanse gently, twice daily',
          'Use lukewarm water and a mild, fragrance-free cleanser. Hot water and harsh scrubs inflame spots and delay healing. Pat dry — never rub.'),
      SkinSection('Treat, then moisturize',
          'Apply acne treatment to dry skin first, then a light non-comedogenic moisturizer. Skipping moisturizer makes skin produce more oil, not less.'),
      SkinSection('Hands off',
          'Picking and squeezing pushes bacteria deeper and risks scars that last years. If a spot tempts you, cover it with a hydrocolloid patch instead.'),
      SkinSection('Sun protection matters',
          'Many acne treatments increase sun sensitivity. A broad-spectrum SPF 30 every morning prevents dark marks from lingering for months.'),
      SkinSection('When to escalate',
          'See a dermatologist if acne is painful, cystic, scarring, or affecting your confidence. Effective prescription options exist — suffering is optional.'),
    ],
  ),
  SkinArticle(
    id: 'eczema-calm', title: 'Calming Eczema Flares Step by Step',
    minutes: 5,
    intro: 'Eczema flares feel chaotic. A fixed sequence brings them under control.',
    sections: [
      SkinSection('The soak-and-seal method',
          'Bathe 5–10 minutes in lukewarm water, then apply moisturizer within 3 minutes of toweling off. This locks water into dry skin better than any expensive cream alone.'),
      SkinSection('Know your triggers',
          'Common ones: fragranced products, wool, heat, sweat, stress, harsh soaps. Change one variable at a time and note flares for two weeks to find yours.'),
      SkinSection('Itch first-aid',
          'Cold compress for 10 minutes, then moisturizer. Keep nails short. At night, cotton gloves stop unconscious scratching that undoes daytime progress.'),
      SkinSection('Steroid creams without fear',
          'Prescribed mild steroids used as directed are safe and effective. The danger is in unmonitored long-term use — follow your clinician\u2019s schedule exactly.'),
      SkinSection('Red flags',
          'Yellow crusts, pus, rapidly spreading redness with fever, or eczema covering large areas need prompt medical review — these signal infection.'),
    ],
  ),
  SkinArticle(
    id: 'psoriasis-basics', title: 'Living Well with Psoriasis',
    minutes: 6,
    intro: 'Psoriasis is manageable. Understanding it is the first treatment.',
    sections: [
      SkinSection('What is actually happening',
          'Your immune system speeds skin-cell turnover from weeks to days. Cells pile up into scaly plaques. It is not contagious — you cannot catch or spread it.'),
      SkinSection('Daily skin strategy',
          'Fragrance-free moisturizers twice daily, lukewarm short showers, and gentle scale-softening (salicylic-acid preparations as advised) reduce thickness and itch.'),
      SkinSection('Triggers worth tracking',
          'Stress, skin injury (even scratches), certain medicines, alcohol, and strep throat can trigger flares. A simple diary reveals your personal pattern.'),
      SkinSection('Treatment ladder',
          'Care steps up logically: moisturizers → prescribed topicals → light therapy → systemic medicines. Each step exists because the previous wasn\u2019t enough — ask your dermatologist where you stand.'),
      SkinSection('Joints matter too',
          'Stiff, swollen joints with psoriasis may signal psoriatic arthritis, which needs early treatment to prevent damage. Report joint symptoms promptly.'),
    ],
  ),
  SkinArticle(
    id: 'sunscreen-mastery', title: 'Sunscreen: The Complete Practical Guide',
    minutes: 5,
    intro: 'The single highest-impact skincare habit. Most people apply too little.',
    sections: [
      SkinSection('How much is enough',
          'Two finger-lengths of product for face and neck. A pea-sized dab — the most common amount — gives a fraction of the labeled SPF.'),
      SkinSection('Reading the label',
          'SPF measures UVB burn protection; look for broad-spectrum or PA+++ for UVA aging protection. SPF 30 blocks ~97% of UVB — higher numbers add marginally.'),
      SkinSection('Reapplication rules',
          'Every 2 hours outdoors, and after swimming or heavy sweating. No sunscreen survives a full beach day in one coat.'),
      SkinSection('For darker skin tones',
          'Melanin protects partly but not fully — dark spots, uneven tone, and skin cancers still occur. Gel or fluid formulas avoid white cast.'),
      SkinSection('Beyond the bottle',
          'Shade between 10 AM and 4 PM, wide-brim hats, and sunglasses do work sunscreen cannot. Layers beat any single product.'),
    ],
  ),
  SkinArticle(
    id: 'dry-skin-fix', title: 'Fixing Chronically Dry Skin',
    minutes: 4,
    intro: 'Dry skin is usually a routine problem, not a product shortage.',
    sections: [
      SkinSection('Stop stripping it',
          'Hot water, foaming sulfates, and long showers dissolve skin oils. Switch to lukewarm 5-minute showers with a creamy cleanser.'),
      SkinSection('Layer like winter clothing',
          'Humectant (glycerin/hyaluronic serum on damp skin) → emollient cream → occlusive layer (petrolatum on cracks). Each layer multiplies the last.'),
      SkinSection('Your home matters',
          'Indoor heating and dry winters pull moisture from skin. A bedroom humidifier plus overnight ointment on hands and feet transforms mornings.'),
      SkinSection('When dryness warns',
          'Sudden severe dryness with thirst, fatigue, or weight change deserves a medical check (thyroid, diabetes). Persistent cracked bleeding skin needs review too.'),
    ],
  ),
  SkinArticle(
    id: 'oily-skin-balance', title: 'Balancing Oily Skin Without Stripping',
    minutes: 4,
    intro: 'Oily skin needs balance, not punishment. Stripping backfires.',
    sections: [
      SkinSection('Why stripping fails',
          'Harsh cleansers and alcohol toners trigger rebound oil within hours. Skin overproduces oil to replace what you removed.'),
      SkinSection('The balanced routine',
          'Gentle gel cleanser, lightweight niacinamide serum, oil-free gel moisturizer, matte sunscreen. Blotting papers for midday shine — not extra washing.'),
      SkinSection('Ingredients that help',
          'Niacinamide (oil regulation), salicylic acid (pore clearing), clay masks weekly (not daily). Introduce one at a time, two weeks apart.'),
      SkinSection('Diet and hormones note',
          'High-glycemic diets and hormonal shifts influence oil for some people. Track patterns, but be skeptical of miracle-food claims.'),
    ],
  ),
  SkinArticle(
    id: 'fungal-prevention', title: 'Preventing Fungal Skin Infections',
    minutes: 4,
    intro: 'Warmth plus moisture grows fungus. Your habits are the treatment.',
    sections: [
      SkinSection('Dry the folds',
          'Feet (between toes), groin, and under-breast areas must be dried fully after bathing. Fungi colonize damp skin within hours.'),
      SkinSection('Stop sharing the vectors',
          'Towels, socks, shoes, razors, and gym mats carry fungi. Personal items stay personal; gym equipment gets wiped before and after.'),
      SkinSection('Treat early and completely',
          'Antifungal cream at the first ring or itch, applied slightly beyond the visible edge, for the FULL course even after it looks healed. Stopping early guarantees recurrence.'),
      SkinSection('When it is not fungus',
          'Eczema and psoriasis mimic ringworm — steroid cream on fungus worsens it. If a "ringworm" resists two weeks of antifungal, get a proper diagnosis.'),
    ],
  ),
  SkinArticle(
    id: 'sensitive-skin', title: 'A Survival Guide for Sensitive Skin',
    minutes: 4,
    intro: 'Sensitive skin reacts to everything. The fix is subtraction, not addition.',
    sections: [
      SkinSection('The 3-product reset',
          'Strip back to cleanser + moisturizer + sunscreen for two weeks. Most "sensitivity" is a damaged barrier from too many actives.'),
      SkinSection('Reading labels like a detective',
          'Fragrance (including "natural" essential oils), drying alcohols, and strong acids top the irritant list. Fewer ingredients means fewer suspects.'),
      SkinSection('Patch-test everything',
          'New product behind the ear or jawline, once daily for 5–7 days. No reaction means facial clearance. This single habit prevents most disasters.'),
      SkinSection('Flushing vs allergy',
          'Temporary warmth after products differs from true allergy (hives, swelling, spreading rash). The latter needs medical review, not a new serum.'),
    ],
  ),
  SkinArticle(
    id: 'wound-scab-care', title: 'Cuts, Scrapes and Scabs: Heal Cleanly',
    minutes: 4,
    intro: 'Proper wound care is the difference between invisible healing and a scar.',
    sections: [
      SkinSection('Clean, don\u2019t sterilize aggressively',
          'Rinse under clean running water, mild soap around (not inside) the wound. Hydrogen peroxide and alcohol damage healing tissue — skip them.'),
      SkinSection('Moist heals faster',
          'Petroleum jelly plus a bandage heals wounds up to twice as fast as air-drying, with less scarring. Change daily or when wet.'),
      SkinSection('Watch the warning signs',
          'Increasing pain after day two, spreading redness, warmth, swelling, pus, red streaks, or fever mean infection — seek care promptly, especially with diabetes.'),
      SkinSection('Scar minimization',
          'Once closed, silicone gel and sun protection for months fade scars best. Picking scabs restarts the clock and deepens marks.'),
    ],
  ),
  SkinArticle(
    id: 'aging-gracefully', title: 'Skin Aging: What Actually Works',
    minutes: 5,
    intro: 'Ninety percent of visible aging is sun damage. Everything else is details.',
    sections: [
      SkinSection('The proven trio',
          'Daily sunscreen, retinoids at night (start low, twice weekly), and moisturizer. These three have decades of evidence; little else does.'),
      SkinSection('Retinoid survival guide',
          'Pea-sized amount, dry skin, moisturizer sandwich method. Expect 4–6 weeks of mild flaking — that is adaptation, not damage. Pregnant: avoid entirely.'),
      SkinSection('Lifestyle compounds interest',
          'Smoking, excess sun, chronic sleep loss, and high sugar visibly age skin over years. No cream outruns these.'),
      SkinSection('Procedures, honestly',
          'Chemical peels, lasers, and injectables work but need qualified providers and real downtime. Beware bargain offers — faces are not discount goods.'),
      SkinSection('When spots warn',
          'New dark irregular moles, changing spots, or sores that don\u2019t heal in weeks need dermatology review — early checks save lives.'),
    ],
  ),
];
