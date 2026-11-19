use std::{borrow::Cow, panic::catch_unwind, slice, str, sync::OnceLock};

use lindera::{mode::Mode, segmenter::Segmenter, LinderaResult};
use unicode_normalization::UnicodeNormalization;

static SEGMENTER: OnceLock<LinderaResult<Segmenter>> = OnceLock::new();
const MAX_LEXEMES: usize = 16_383;
const MAX_LEXEME_BYTES: usize = 2_046;

fn analyze(input: &str) -> Result<String, ()> {
    let segmenter = SEGMENTER
        .get_or_init(|| {
            let dictionary = lindera_ko_dic::embedded::load()?;
            Ok(Segmenter::new(Mode::Normal, dictionary, None))
        })
        .as_ref()
        .map_err(|_| ())?;
    let normalized: String = input.nfc().collect();
    let mut tokens = segmenter
        .segment(Cow::Borrowed(&normalized))
        .map_err(|_| ())?;
    let mut output = String::new();
    let mut count = 0;
    for token in &mut tokens {
        // Particles, endings and derivational verb/adjective suffixes are not search terms.
        if token.get_detail(0).is_some_and(|tag| {
            tag.starts_with(['J', 'E']) || matches!(tag, "XSV" | "XSA" | "VCP" | "VCN")
        }) {
            continue;
        }
        for word in token
            .surface
            .split(|c: char| !c.is_alphanumeric())
            .filter(|w| !w.is_empty())
        {
            let lexeme: String = word.chars().flat_map(char::to_lowercase).collect();
            if count == MAX_LEXEMES || lexeme.len() > MAX_LEXEME_BYTES {
                return Err(());
            }
            if count > 0 {
                output.push(' ');
            }
            output.push_str(&lexeme);
            count += 1;
        }
    }
    Ok(output)
}

// Returns the byte count (even when the buffer is too small) or -1 on failure.
#[no_mangle]
unsafe extern "C" fn kor_native_analyze(
    input: *const u8,
    len: usize,
    output: *mut u8,
    capacity: usize,
) -> isize {
    catch_unwind(|| {
        let Ok(input) = str::from_utf8(unsafe { slice::from_raw_parts(input, len) }) else {
            return -1;
        };
        let Ok(analyzed) = analyze(input) else {
            return -1;
        };
        if analyzed.len() <= capacity {
            // The caller owns separate input and output buffers, valid for this call only.
            unsafe { output.copy_from_nonoverlapping(analyzed.as_ptr(), analyzed.len()) };
        }
        analyzed.len() as isize
    })
    .unwrap_or(-1)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn handles_particles_mixed_text_and_nfc() {
        assert_eq!(analyze("삼성에서 Samsung").unwrap(), "삼성 samsung");
        let nfd: String = "철근 콘크리트".nfd().collect();
        assert_eq!(analyze(&nfd), analyze("철근 콘크리트"));
        assert_eq!(analyze("! …").unwrap(), "");
    }
}
